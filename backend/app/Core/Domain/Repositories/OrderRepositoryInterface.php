<?php

namespace App\Core\Domain\Repositories;

use App\Models\Order;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface OrderRepositoryInterface
{
    public function findById(int $id): ?Order;

    public function findByOrderNumber(string $orderNumber): ?Order;

    public function create(array $data): Order;

    public function update(Order $order, array $data): Order;

    public function delete(Order $order): bool;

    public function updateStatus(Order $order, string $status): Order;

    public function updatePaymentStatus(Order $order, string $paymentStatus): Order;

    public function paginateForCustomer(int $customerId, int $perPage = 15): LengthAwarePaginator;

    public function paginateForVendor(int $vendorId, int $perPage = 15): LengthAwarePaginator;

    public function paginateForDriver(int $driverId, int $perPage = 15): LengthAwarePaginator;

    public function findPendingForDriverAssignment(int $limit = 10): array;

    public function countByStatus(string $status): int;

    public function sumRevenue(): float;
}
