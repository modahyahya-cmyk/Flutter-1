<?php

namespace App\Core\Infrastructure\Services;

use App\Exceptions\BusinessException;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\Http;

class RazorpayPaymentService implements PaymentGatewayInterface
{
    public function init(Order $order, string $reference): array
    {
        $response = $this->request('POST', 'https://api.razorpay.com/v1/orders', [
            'amount' => (int) round($order->total_amount * 100),
            'currency' => config('app_settings.localization.default_currency', 'USD'),
            'receipt' => $reference,
        ]);

        if ($response['status_code'] >= 400) {
            throw new BusinessException('Razorpay order initialization failed.');
        }

        return [
            'provider_reference' => $response['id'],
            'razorpay_order_id' => $response['id'],
        ];
    }

    public function redirect(Order $order, string $reference): array
    {
        $payment = Payment::where('payment_reference', $reference)->first();

        return [
            'checkout_url' => config('app.url').'/payment/razorpay?reference='.$reference,
            'provider' => 'razorpay',
            'reference' => $reference,
            'order_id' => $payment->provider_reference,
        ];
    }

    public function verify(Payment $payment): array
    {
        $response = $this->request('GET', "https://api.razorpay.com/v1/orders/{$payment->provider_reference}/payments");

        $items = $response['items'] ?? [];
        $payments = is_array($items) ? $items : [];

        $success = collect($payments)->contains(fn ($p) => (($p['status'] ?? '') === 'captured') && (($p['captured'] ?? false) === true));

        return [
            'success' => $success,
            'provider_reference' => $payment->provider_reference,
            'amount' => $success ? (float) ($payments[0]['amount'] ?? 0) / 100 : 0,
        ];
    }

    public function webhook(array $payload): array
    {
        return [
            'success' => ($payload['event'] ?? '') === 'payment.captured',
            'reference' => $payload['payload']['payment']['entity']['order_id'] ?? null,
        ];
    }

    public function refund(Payment $payment, float $amount): array
    {
        $payerId = $this->getCapturedPaymentId($payment->provider_reference);

        $response = $this->request('POST', "https://api.razorpay.com/v1/payments/{$payerId}/refund", [
            'amount' => (int) round($amount * 100),
        ]);

        if ($response['status_code'] >= 400) {
            throw new BusinessException('Razorpay refund failed.');
        }

        return ['success' => true, 'provider_reference' => $payment->provider_reference];
    }

    private function getCapturedPaymentId(string $orderId): string
    {
        $response = $this->request('GET', "https://api.razorpay.com/v1/orders/{$orderId}/payments");
        $items = $response['items'] ?? [];

        return collect($items)->firstWhere('status', 'captured')['id'] ?? '';
    }

    private function request(string $method, string $url, array $body = []): array
    {
        $keyId = config('app_settings.payment_gateways.razorpay.key_id', '');
        $keySecret = config('app_settings.payment_gateways.razorpay.key_secret', '');

        $response = Http::withBasicAuth($keyId, $keySecret)
            ->{$method === 'GET' ? 'get' : 'post'}($url, $body);

        return array_merge($response->json() ?? [], ['status_code' => $response->status()]);
    }
}
