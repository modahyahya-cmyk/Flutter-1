<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\DeliveryRepositoryInterface;
use App\Models\Delivery;
use App\Models\Order;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentDeliveryRepository implements DeliveryRepositoryInterface
{
    public function findById(int $id): ?Delivery
    {
        return Delivery::with(['order', 'order.vendor', 'order.customer'])->find($id);
    }

    public function findByOrder(int $orderId): ?Delivery
    {
        return Delivery::where('order_id', $orderId)->first();
    }

    public function createForOrder(Order $order, int $driverId): Delivery
    {
        $branch = $order->branch;
        $pickup = $branch ? [$branch->latitude, $branch->longitude] : [null, null];

        return Delivery::create([
            'order_id' => $order->id,
            'driver_id' => $driverId,
            'pickup_latitude' => $pickup[0],
            'pickup_longitude' => $pickup[1],
            'dropoff_latitude' => $order->delivery_latitude,
            'dropoff_longitude' => $order->delivery_longitude,
            'distance_km' => $order->delivery_distance_km ?? 0,
            'fee' => $order->delivery_fee,
            'driver_earning' => $order->delivery_fee,
            'status' => 'assigned',
            'assigned_at' => now(),
        ]);
    }

    public function updateStatus(Delivery $delivery, string $status, array $data = []): Delivery
    {
        $timestamps = match ($status) {
            'picked_up' => ['picked_up_at' => now()],
            'delivered' => ['delivered_at' => now()],
            'cancelled' => ['cancelled_at' => now()],
            default => [],
        };

        $delivery->update(array_merge(['status' => $status], $timestamps, array_filter([
            'dropoff_latitude' => $data['latitude'] ?? null,
            'dropoff_longitude' => $data['longitude'] ?? null,
        ], fn ($v) => $v !== null)));

        return $delivery->fresh();
    }

    public function paginateForDriver(int $driverId, int $perPage = 15): LengthAwarePaginator
    {
        return Delivery::where('driver_id', $driverId)
            ->with(['order', 'order.vendor', 'order.customer'])
            ->latest()
            ->paginate($perPage);
    }

    public function countDeliveredByDriver(int $driverId): int
    {
        return Delivery::where('driver_id', $driverId)->where('status', 'delivered')->count();
    }
}
