<?php

namespace App\Core\Presentation\API\V1\Controllers\Driver;

use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\DriverResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LocationController extends BaseController
{
    public function __construct(private DriverRepositoryInterface $drivers)
    {
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'is_online' => ['nullable', 'boolean'],
        ]);

        $user = $request->attributes->get('user');
        $driver = $this->drivers->findByUserId($user->id);

        abort_if($driver === null, 403, 'No driver profile linked to this account.');

        $driver = $this->drivers->update($driver, [
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'last_location_at' => now(),
            'is_online' => $validated['is_online'] ?? $driver->is_online,
        ]);

        return $this->success(DriverResource::make($driver), 'Location updated.');
    }

    /**
     * Batch upload of GPS points accumulated offline by the driver client.
     */
    public function storeBatch(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'points' => ['required', 'array', 'min:1', 'max:500'],
            'points.*.latitude' => ['required', 'numeric', 'between:-90,90'],
            'points.*.longitude' => ['required', 'numeric', 'between:-180,180'],
            'points.*.accuracy' => ['nullable', 'numeric', 'min:0', 'max:1000'],
            'points.*.speed_kmh' => ['nullable', 'numeric', 'min:0', 'max:400'],
            'points.*.heading_deg' => ['nullable', 'numeric', 'between:0,360'],
            'points.*.altitude_m' => ['nullable', 'numeric'],
            'points.*.captured_at' => ['nullable', 'date'],
        ]);

        $user = $request->attributes->get('user');
        $driver = $this->drivers->findByUserId($user->id);

        abort_if($driver === null, 403, 'No driver profile linked to this account.');

        $persisted = $this->drivers->batchStoreLocations($driver, $validated['points']);

        return $this->success(
            ['driver_id' => $driver->id, 'persisted' => $persisted, 'received' => count($validated['points'])],
            'Location batch stored.'
        );
    }

    public function setOnline(Request $request): JsonResponse
    {
        $validated = $request->validate(['is_online' => ['required', 'boolean']]);

        $user = $request->attributes->get('user');
        $driver = $this->drivers->findByUserId($user->id);

        abort_if($driver === null, 403, 'No driver profile linked to this account.');

        $driver = $this->drivers->setOnline($driver, $validated['is_online']);

        return $this->success(DriverResource::make($driver), $validated['is_online'] ? 'You are now online.' : 'You are now offline.');
    }
}
