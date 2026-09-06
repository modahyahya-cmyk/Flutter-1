<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Models\Driver;
use App\Models\LocationHistory;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class EloquentDriverRepository implements DriverRepositoryInterface
{
    public function findById(int $id): ?Driver
    {
        return Driver::with('user')->find($id);
    }

    public function findByUserId(int $userId): ?Driver
    {
        return Driver::where('user_id', $userId)->first();
    }

    public function create(array $data): Driver
    {
        return Driver::create($data);
    }

    public function update(Driver $driver, array $data): Driver
    {
        $driver->update($data);

        return $driver->fresh();
    }

    public function delete(Driver $driver): bool
    {
        return (bool) $driver->delete();
    }

    public function approve(Driver $driver): Driver
    {
        return $this->update($driver, [
            'status' => 'approved',
            'rejection_reason' => null,
            'is_verified' => true,
            'approved_at' => now(),
        ]);
    }

    public function reject(Driver $driver, string $reason): Driver
    {
        return $this->update($driver, [
            'status' => 'rejected',
            'rejection_reason' => $reason,
            'is_online' => false,
        ]);
    }

    public function setOnline(Driver $driver, bool $online): Driver
    {
        return $this->update($driver, ['is_online' => $online]);
    }

    public function findAvailableNearby(float $lat, float $lng, float $radiusKm): array
    {
        $haversine = DB::raw(
            '(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance'
        );

        return Driver::select('*')
            ->addSelect($haversine)
            ->where('status', 'approved')
            ->where('is_online', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->having('distance', '<=', $radiusKm)
            ->orderBy('distance')
            ->with('user')
            ->setBindings([$lat, $lng, $lat])
            ->get()
            ->all();
    }

    public function paginate(int $perPage = 15, string $status = null): LengthAwarePaginator
    {
        $query = Driver::with('user');

        if ($status !== null) {
            $query->where('status', $status);
        }

        return $query->latest()->paginate($perPage);
    }

    public function countOnline(): int
    {
        return Driver::where('is_online', true)->where('status', 'approved')->count();
    }

    public function batchStoreLocations(Driver $driver, array $points): int
    {
        return DB::transaction(function () use ($driver, $points) {
            $rows = [];

            foreach ($points as $point) {
                $rows[] = [
                    'uuid' => (string) Str::uuid(),
                    'driver_id' => $driver->id,
                    'latitude' => $point['latitude'],
                    'longitude' => $point['longitude'],
                    'accuracy' => $point['accuracy'] ?? null,
                    'speed_kmh' => $point['speed_kmh'] ?? null,
                    'heading_deg' => $point['heading_deg'] ?? null,
                    'altitude_m' => $point['altitude_m'] ?? null,
                    'captured_at' => $point['captured_at'] ?? now()->toDateTimeString(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            LocationHistory::insert($rows);

            // Move the driver's "current" position to the newest point in the batch.
            $latest = $rows[count($rows) - 1];
            $driver->update([
                'latitude' => $latest['latitude'],
                'longitude' => $latest['longitude'],
                'last_location_at' => $latest['captured_at'],
            ]);

            return count($rows);
        });
    }
}
