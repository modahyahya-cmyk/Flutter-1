<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Services\PaymentServiceInterface;
use App\Exceptions\BusinessException;
use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Foundation payment service. Concrete gateway logic (Stripe/Paystack/Razorpay)
 * lives in dedicated adapter classes so the rest of the application never
 * depends on a specific provider. This class orchestrates the gateway-agnostic
 * flow and persists payment records.
 */
class PaymentService implements PaymentServiceInterface
{
    public function initializePayment(Order $order, string $provider, User $user): array
    {
        $this->assertProviderConfigured($provider);

        $reference = 'PAY-'.strtoupper(Str::orderedUuid()->toString());

        DB::transaction(function () use ($order, $provider, $user, $reference) {
            $gateway = $this->resolveGateway($provider);
            $init = $gateway->init($order, $reference);

            Payment::create([
                'payment_reference' => $reference,
                'order_id' => $order->id,
                'user_id' => $user->id,
                'vendor_id' => $order->vendor_id,
                'provider' => $provider,
                'provider_reference' => $init['provider_reference'] ?? null,
                'amount' => $order->total_amount,
                'net_amount' => $order->total_amount,
                'currency' => config('app_settings.localization.default_currency', 'USD'),
                'status' => 'pending',
            ]);
        });

        $gateway = $this->resolveGateway($provider);

        return $gateway->redirect($order, $reference);
    }

    public function verifyPayment(string $reference): array
    {
        $payment = Payment::where('payment_reference', $reference)->first();
        abort_if($payment === null, 404, 'Payment not found.');

        $gateway = $this->resolveGateway($payment->provider);
        $result = $gateway->verify($payment);

        if ($result['success']) {
            $payment->update([
                'status' => 'completed',
                'paid_at' => now(),
                'provider_reference' => $result['provider_reference'] ?? $payment->provider_reference,
            ]);

            $payment->order?->update(['payment_status' => 'completed']);
        }

        return $result;
    }

    public function handleWebhook(string $provider, array $payload): array
    {
        $gateway = $this->resolveGateway($provider);

        return $gateway->webhook($payload);
    }

    /**
     * Marks a payment (and its order) as completed, idempotently. Safe to call
     * repeatedly (webhook retries, double-tap, concurrent requests): a payment
     * already terminal is returned untouched and the order is only upgraded once.
     */
    public function markCompleted(Payment $payment): Payment
    {
        return DB::transaction(function () use ($payment) {
            $locked = Payment::whereKey($payment->id)->lockForUpdate()->first();
            if ($locked === null) {
                throw new BusinessException('Payment not found.');
            }

            if ($locked->status === 'completed') {
                return $locked; // idempotent: already processed
            }

            if ($locked->status === 'refunded' || $locked->status === 'partially_refunded') {
                throw new BusinessException('A refunded payment cannot be marked completed.');
            }

            $locked->update([
                'status' => 'completed',
                'paid_at' => $locked->paid_at ?? now(),
            ]);

            $order = $locked->order;
            if ($order !== null && $order->payment_status !== 'completed') {
                $order->update(['payment_status' => 'completed']);
            }

            return $locked->fresh();
        });
    }

    public function refund(Order $order, float $amount = null): array
    {
        $payment = Payment::where('order_id', $order->id)
            ->where('status', 'completed')
            ->latest()
            ->first();

        abort_if($payment === null, 422, 'No completed payment to refund.');

        $gateway = $this->resolveGateway($payment->provider);
        $result = $gateway->refund($payment, $amount ?? $payment->amount);

        if ($result['success']) {
            $payment->update([
                'status' => 'refunded',
                'refunded_at' => now(),
            ]);
            $order->update(['payment_status' => 'refunded']);
        }

        return $result;
    }

    public function isConfigured(string $provider): bool
    {
        $config = config("app_settings.payment_gateways.{$provider}");

        return $config !== null && ($config['enabled'] ?? false);
    }

    private function resolveGateway(string $provider): PaymentGatewayInterface
    {
        return match ($provider) {
            'stripe' => app(StripePaymentService::class),
            'paystack' => app(PaystackPaymentService::class),
            'razorpay' => app(RazorpayPaymentService::class),
            'cash_on_delivery' => app(CashOnDeliveryService::class),
            default => throw new BusinessException("Unsupported payment provider: {$provider}"),
        };
    }

    private function assertProviderConfigured(string $provider): void
    {
        if (! $this->isConfigured($provider)) {
            throw new BusinessException("The {$provider} payment gateway is not enabled.");
        }
    }
}
