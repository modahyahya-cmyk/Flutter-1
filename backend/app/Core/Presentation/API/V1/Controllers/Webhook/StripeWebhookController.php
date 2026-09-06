<?php

namespace App\Core\Presentation\API\V1\Controllers\Webhook;

use App\Core\Domain\Services\PaymentServiceInterface;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Stripe\Webhook;

class StripeWebhookController
{
    public function __construct(private PaymentServiceInterface $payments)
    {
    }

    /**
     * Stripe webhook receiver.
     *
     * - Verifies the Stripe-Signature using the configured webhook secret
     *   (fails closed: a missing/incorrect secret rejects the request).
     * - Processes the event idempotently: a payment already completed is left
     *   untouched, so webhook retries / duplicate deliveries cannot double
     *   charge or double-mark anything.
     * - Returns 400 on an invalid signature, 200 once processed, and 500 on a
     *   processing failure so Stripe retries.
     */
    public function handle(Request $request): JsonResponse
    {
        $payload = (string) $request->getContent();
        $signatureHeader = (string) $request->header('Stripe-Signature', '');
        $secret = (string) config('app_settings.payment_gateways.stripe.webhook_secret', '');

        if ($secret === '') {
            return response()->json(['success' => false, 'message' => 'Stripe webhook secret is not configured.'], 400);
        }

        try {
            $event = Webhook::constructEvent($payload, $signatureHeader, $secret);
        } catch (\Throwable $e) {
            return response()->json(['success' => false, 'message' => 'Invalid Stripe signature.'], 400);
        }

        try {
            $this->processEvent($event);
        } catch (\Throwable $e) {
            report($e);

            return response()->json(['success' => false, 'message' => 'Webhook processing failed.'], 500);
        }

        return response()->json(['success' => true]);
    }

    private function processEvent(\Stripe\Event $event): void
    {
        $type = $event->type ?? '';
        if (! in_array($type, ['checkout.session.completed', 'payment_intent.succeeded', 'payment_intent.payment_failed'], true)) {
            return; // Ignore unrelated event types.
        }

        $object = $event->data->object ?? null;
        if ($object === null) {
            return;
        }

        $reference = $object->metadata->reference ?? null;
        if ($reference === null) {
            return;
        }

        $payment = Payment::where('payment_reference', $reference)->first();
        if ($payment === null) {
            return;
        }

        if (str_contains($type, 'payment_failed')) {
            if ($payment->status !== 'completed') {
                $payment->update(['status' => 'failed']);
                $payment->order?->update(['payment_status' => 'failed']);
            }

            return;
        }

        // Idempotent completion (webhook retries / duplicate events).
        if ($payment->provider_reference === null && isset($object->id)) {
            $payment->update(['provider_reference' => (string) $object->id]);
        }

        $this->payments->markCompleted($payment->fresh());
    }
}
