<?php

namespace App\Core\Domain\Services;

use App\Models\Order;
use App\Models\Payment;
use App\Models\User;

interface PaymentServiceInterface
{
    public function initializePayment(Order $order, string $provider, User $user): array;

    public function verifyPayment(string $reference): array;

    public function handleWebhook(string $provider, array $payload): array;

    public function refund(Order $order, float $amount = null): array;

    public function isConfigured(string $provider): bool;

    /**
     * Marks a payment + its order completed, idempotently (safe for webhook
     * retries, duplicate clicks and concurrent requests).
     */
    public function markCompleted(Payment $payment): Payment;
}
