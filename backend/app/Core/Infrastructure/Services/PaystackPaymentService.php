<?php

namespace App\Core\Infrastructure\Services;

use App\Exceptions\BusinessException;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\Http;

class PaystackPaymentService implements PaymentGatewayInterface
{
    public function init(Order $order, string $reference): array
    {
        $response = Http::withToken(config('app_settings.payment_gateways.paystack.secret_key', ''))
            ->post('https://api.paystack.co/transaction/initialize', [
                'reference' => $reference,
                'email' => $order->customer?->email,
                'amount' => (int) round($order->total_amount * 100),
                'metadata' => [
                    'order_number' => $order->order_number,
                    'reference' => $reference,
                ],
            ]);

        if ($response->failed()) {
            throw new BusinessException('Paystack initialization failed.');
        }

        $data = $response->json('data');

        return [
            'provider_reference' => $data['reference'] ?? $reference,
            'authorization_url' => $data['authorization_url'] ?? null,
        ];
    }

    public function redirect(Order $order, string $reference): array
    {
        $payment = Payment::where('payment_reference', $reference)->first();

        $response = Http::withToken(config('app_settings.payment_gateways.paystack.secret_key', ''))
            ->get("https://api.paystack.co/transaction/verify/{$payment->provider_reference}");

        return [
            'checkout_url' => $response->json('data.authorization_url'),
            'provider' => 'paystack',
            'reference' => $reference,
        ];
    }

    public function verify(Payment $payment): array
    {
        $response = Http::withToken(config('app_settings.payment_gateways.paystack.secret_key', ''))
            ->get("https://api.paystack.co/transaction/verify/".$payment->provider_reference);

        $status = $response->json('data.status');

        return [
            'success' => $status === 'success',
            'provider_reference' => $payment->provider_reference,
            'amount' => ($response->json('data.amount') ?? 0) / 100,
        ];
    }

    public function webhook(array $payload): array
    {
        return [
            'success' => ($payload['event'] ?? '') === 'charge.success',
            'reference' => $payload['data']['reference'] ?? null,
        ];
    }

    public function refund(Payment $payment, float $amount): array
    {
        $response = Http::withToken(config('app_settings.payment_gateways.paystack.secret_key', ''))
            ->post("https://api.paystack.co/transaction/refund", [
                'transaction' => $payment->provider_reference,
                'amount' => (int) round($amount * 100),
            ]);

        if ($response->failed()) {
            throw new BusinessException('Paystack refund failed.');
        }

        return ['success' => true, 'provider_reference' => $payment->provider_reference];
    }
}
