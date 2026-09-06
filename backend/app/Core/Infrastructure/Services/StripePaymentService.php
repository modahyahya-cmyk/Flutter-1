<?php

namespace App\Core\Infrastructure\Services;

use App\Exceptions\BusinessException;
use App\Models\Order;
use App\Models\Payment;
use Stripe\Checkout\Session as StripeSession;
use Stripe\Stripe;

class StripePaymentService implements PaymentGatewayInterface
{
    public function init(Order $order, string $reference): array
    {
        $this->configure();

        $session = StripeSession::create([
            'payment_method_types' => ['card'],
            'line_items' => [[
                'price_data' => [
                    'currency' => strtolower(config('app_settings.localization.default_currency', 'USD')),
                    'product_data' => ['name' => "Order {$order->order_number}"],
                    'unit_amount' => (int) round($order->total_amount * 100),
                ],
                'quantity' => 1,
            ]],
            'mode' => 'payment',
            'success_url' => config('app.url')."/payment/success?reference={$reference}",
            'cancel_url' => config('app.url').'/payment/cancel',
            'metadata' => [
                'order_number' => $order->order_number,
                'reference' => $reference,
            ],
        ]);

        return [
            'provider_reference' => $session->id,
            'checkout_url' => $session->url,
        ];
    }

    public function redirect(Order $order, string $reference): array
    {
        $session = StripeSession::retrieve(
            Payment::where('payment_reference', $reference)->value('provider_reference')
        );

        return [
            'checkout_url' => $session->url,
            'provider' => 'stripe',
            'reference' => $reference,
        ];
    }

    public function verify(Payment $payment): array
    {
        $this->configure();

        $session = StripeSession::retrieve($payment->provider_reference);

        $success = $session->payment_status === 'paid';

        return [
            'success' => $success,
            'provider_reference' => $session->id,
            'amount' => $success ? ($session->amount_total / 100) : 0,
        ];
    }

    public function webhook(array $payload): array
    {
        $eventType = $payload['type'] ?? '';
        $reference = $payload['data']['object']['metadata']['reference'] ?? null;

        return [
            'success' => in_array($eventType, ['payment_intent.succeeded', 'checkout.session.completed'], true),
            'reference' => $reference,
        ];
    }

    public function refund(Payment $payment, float $amount): array
    {
        $this->configure();

        try {
            \Stripe\Refund::create([
                'payment_intent' => $payment->provider_reference,
                'amount' => (int) round($amount * 100),
            ]);

            return ['success' => true, 'provider_reference' => $payment->provider_reference];
        } catch (\Throwable $e) {
            throw new BusinessException('Stripe refund failed: '.$e->getMessage());
        }
    }

    private function configure(): void
    {
        Stripe::setApiKey(config('app_settings.payment_gateways.stripe.secret_key', ''));
    }
}
