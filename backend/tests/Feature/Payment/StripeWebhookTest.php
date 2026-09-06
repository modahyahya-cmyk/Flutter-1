<?php

namespace Tests\Feature\Payment;

use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithoutMiddleware;
use Tests\TestCase;

class StripeWebhookTest extends TestCase
{
    use RefreshDatabase, WithoutMiddleware;

    private string $secret = 'whsec_test_secret_not_for_production';

    protected function setUp(): void
    {
        parent::setUp();
        config(['app_settings.payment_gateways.stripe.webhook_secret' => $this->secret]);
    }

    public function test_webhook_rejects_invalid_signature(): void
    {
        $order = $this->makePendingOrder();
        $payment = $this->makePayment($order, 'pending');

        $this->call('POST', '/api/v1/webhooks/stripe', [], [], [], [],
            json_encode($this->eventPayload($payment))
        )->assertStatus(400);
    }

    public function test_webhook_marks_payment_and_order_completed(): void
    {
        $order = $this->makePendingOrder();
        $payment = $this->makePayment($order, 'pending');

        $this->postWebhook($this->eventPayload($payment));

        $payment->refresh();
        $order->refresh();
        $this->assertSame('completed', $payment->status);
        $this->assertSame('completed', $order->payment_status);
    }

    public function test_webhook_is_idempotent_on_retry(): void
    {
        $order = $this->makePendingOrder();
        $payment = $this->makePayment($order, 'pending');

        $this->postWebhook($this->eventPayload($payment));
        $this->postWebhook($this->eventPayload($payment));

        $this->assertSame(1, Payment::where('order_id', $order->id)->count());
        $this->assertSame('completed', Payment::where('order_id', $order->id)->first()->status);
        $this->assertSame('completed', $order->refresh()->payment_status);
    }

    private function postWebhook(array $payload): void
    {
        $body = json_encode($payload);
        $timestamp = time();
        $signed = "{$timestamp}.{$body}";
        $signature = hash_hmac('sha256', $signed, $this->secret);

        $this->call(
            'POST',
            '/api/v1/webhooks/stripe',
            [],
            [],
            [],
            ['HTTP_Stripe_Signature' => "t={$timestamp},v1={$signature}"],
            $body
        )->assertStatus(200);
    }

    private function eventPayload(Payment $payment): array
    {
        return [
            'type' => 'checkout.session.completed',
            'data' => [
                'object' => [
                    'id' => 'cs_test_123',
                    'metadata' => ['reference' => $payment->payment_reference],
                ],
            ],
        ];
    }

    private function makePendingOrder(): Order
    {
        $user = User::factory()->create();
        $vendor = Vendor::query()->create([
            'user_id' => $user->id,
            'business_name' => 'Test Vendor',
            'slug' => 'test-vendor',
            'status' => 'approved',
        ]);

        return Order::factory()->create([
            'customer_id' => $user->id,
            'vendor_id' => $vendor->id,
            'payment_method' => 'stripe',
            'payment_status' => 'pending',
        ]);
    }

    private function makePayment(Order $order, string $status): Payment
    {
        return Payment::create([
            'payment_reference' => 'PAY-'.strtoupper(str()->random(12)),
            'order_id' => $order->id,
            'user_id' => $order->customer_id,
            'vendor_id' => $order->vendor_id,
            'provider' => 'stripe',
            'amount' => $order->total_amount,
            'net_amount' => $order->total_amount,
            'currency' => 'USD',
            'status' => $status,
        ]);
    }
}
