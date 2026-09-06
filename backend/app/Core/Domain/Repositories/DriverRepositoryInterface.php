<?php

namespace App\Core\Domain\Repositories;

use App\Models\Driver;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface DriverRepositoryInterface
{
    public function findById(int $id): ?Driver;

    public function findByUserId(int $userId): ?Driver;

    public function create(array $data): Driver;

    public function update(Driver $driver, array $data): Driver;

    public function delete(Driver $driver): bool;

    public function approve(Driver $driver): Driver;

    public function reject(Driver $driver, string $reason): Driver;

    public function setOnline(Driver $driver, bool $online): Driver;

    public function findAvailableNearby(float $lat, float $lng, float $radiusKm): array;

    public function paginate(int $perPage = 15, string $status = null): LengthAwarePaginator;

    public function countOnline(): int;

    /**
     * Persist a batch of driver GPS points and update the driver's current
     * position to the latest point in the batch. Runs in a single transaction.
     *
     * @param list<array{latitude:float,longitude:float,accuracy:?float,speed_kmh:?float,heading_deg:?float,altitude_m:?float,captured_at:?string}> $points
     * @return int number of location rows persisted
     */
    public function batchStoreLocations(Driver $driver, array $points): int;
}
