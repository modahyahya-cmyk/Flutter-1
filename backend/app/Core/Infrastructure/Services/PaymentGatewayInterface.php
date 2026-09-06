<?php

namespace App\Core\Infrastructure\Services;

use App\Models\Order;
use App\Models\Payment;

interface PaymentGatewayInterface
{
    public function init(Order $order, string $reference): array;

    public function redirect(Order $order, string $reference): array;

    public function verify(Payment $payment): array;

    public function webhook(array $payload): array;

    public function refund(Payment $payment, float $amount): array;
}
