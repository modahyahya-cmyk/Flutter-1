<?php

namespace App\Core\Infrastructure\Services;

use App\Models\Order;
use App\Models\Payment;

/**
 * Cash on Delivery gateway. No external network call required; it simply
 * records the payment as pending and lets the driver confirm collection.
 */
class CashOnDeliveryService implements PaymentGatewayInterface
{
    public function init(Order $order, string $reference): array
    {
        return ['provider_reference' => $reference];
    }

    public function redirect(Order $order, string $reference): array
    {
        return [
            'checkout_url' => null,
            'provider' => 'cash_on_delivery',
            'reference' => $reference,
            'message' => 'Pay with cash on delivery when your order arrives.',
        ];
    }

    public function verify(Payment $payment): array
    {
        return ['success' => $payment->status === 'completed'];
    }

    public function webhook(array $payload): array
    {
        $order = $payload['order'] ?? null;
        $success = $order && ($order['payment_status'] ?? '') === 'completed';

        return ['success' => (bool) $success, 'reference' => $order['order_number'] ?? null];
    }

    public function refund(Payment $payment, float $amount): array
    {
        return ['success' => false];
    }
}
