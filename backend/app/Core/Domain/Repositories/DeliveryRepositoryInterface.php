<?php

namespace App\Core\Domain\Repositories;

use App\Models\Delivery;
use App\Models\Order;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface DeliveryRepositoryInterface
{
    public function findById(int $id): ?Delivery;

    public function findByOrder(int $orderId): ?Delivery;

    public function createForOrder(Order $order, int $driverId): Delivery;

    public function updateStatus(Delivery $delivery, string $status, array $data = []): Delivery;

    public function paginateForDriver(int $driverId, int $perPage = 15): LengthAwarePaginator;

    public function countDeliveredByDriver(int $driverId): int;
}
