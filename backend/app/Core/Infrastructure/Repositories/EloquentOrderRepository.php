<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Models\Order;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentOrderRepository implements OrderRepositoryInterface
{
    public function findById(int $id): ?Order
    {
        return Order::with(['customer', 'vendor', 'driver', 'items'])->find($id);
    }

    public function findByOrderNumber(string $orderNumber): ?Order
    {
        return Order::where('order_number', $orderNumber)
            ->with(['customer', 'vendor', 'items'])
            ->first();
    }

    public function create(array $data): Order
    {
        return Order::create($data);
    }

    public function update(Order $order, array $data): Order
    {
        $order->update($data);

        return $order->fresh();
    }

    public function delete(Order $order): bool
    {
        return (bool) $order->delete();
    }

    public function updateStatus(Order $order, string $status): Order
    {
        return $this->update($order, ['status' => $status]);
    }

    public function updatePaymentStatus(Order $order, string $paymentStatus): Order
    {
        return $this->update($order, ['payment_status' => $paymentStatus]);
    }

    public function paginateForCustomer(int $customerId, int $perPage = 15): LengthAwarePaginator
    {
        return Order::where('customer_id', $customerId)
            ->with(['vendor'])
            ->latest()
            ->paginate($perPage);
    }

    public function paginateForVendor(int $vendorId, int $perPage = 15): LengthAwarePaginator
    {
        return Order::where('vendor_id', $vendorId)
            ->with(['customer', 'driver'])
            ->latest()
            ->paginate($perPage);
    }

    public function paginateForDriver(int $driverId, int $perPage = 15): LengthAwarePaginator
    {
        return Order::where('driver_id', $driverId)
            ->with(['vendor', 'customer'])
            ->latest()
            ->paginate($perPage);
    }

    public function findPendingForDriverAssignment(int $limit = 10): array
    {
        return Order::where('status', 'confirmed')
            ->where('order_type', 'delivery')
            ->whereNotNull('delivery_latitude')
            ->whereNotNull('delivery_longitude')
            ->orderBy('created_at', 'asc')
            ->limit($limit)
            ->get()
            ->all();
    }

    public function countByStatus(string $status): int
    {
        return Order::where('status', $status)->count();
    }

    public function sumRevenue(): float
    {
        return (float) Order::where('payment_status', 'completed')->sum('total_amount');
    }
}
