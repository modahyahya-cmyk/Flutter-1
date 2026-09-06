<?php

namespace App\Core\Domain\Services;

use App\Models\Delivery;
use App\Models\Driver;
use App\Models\Order;
use App\Models\User;

interface OrderServiceInterface
{
    public function createOrder(User $customer, array $data): Order;

    public function confirmOrder(Order $order): Order;

    /**
     * Authoritative order status transition. Validates the ORDER state machine
     * (legal transition + actor) before mutating. Controllers must use this
     * instead of mutating status directly.
     */
    public function transitionOrder(Order $order, string $to, ?string $actor = null): Order;

    public function cancelOrder(Order $order, string $reason = null, ?string $actor = null): Order;

    public function markDelivered(Order $order): Order;

    /**
     * Atomic, race-safe driver assignment. Exactly one concurrent claim
     * succeeds; the rest fail deterministically.
     */
    public function assignDriver(Order $order, int $driverId): Order;

    /**
     * Authoritative delivery status transition, validated by the DELIVERY
     * state machine. Crediting driver earnings for a delivery is idempotent
     * (only the first transition to "delivered" credits once).
     */
    public function updateDeliveryStatus(Delivery $delivery, string $status, array $data = [], ?Driver $driver = null): Delivery;

    public function calculateTotals(array $items, array $deliveryData = []): array;

    public function getStatusHistory(Order $order): array;
}
