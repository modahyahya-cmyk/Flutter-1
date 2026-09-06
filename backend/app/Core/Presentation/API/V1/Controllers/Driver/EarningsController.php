<?php

namespace App\Core\Presentation\API\V1\Controllers\Driver;

use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\DriverResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class EarningsController extends BaseController
{
    public function __construct(private DriverRepositoryInterface $drivers)
    {
    }

    public function summary(Request $request): JsonResponse
    {
        $user = $request->attributes->get('user');
        $driver = $this->drivers->findByUserId($user->id);

        abort_if($driver === null, 403, 'No driver profile linked to this account.');

        $deliveries = $driver->deliveries()->where('status', 'delivered')
            ->where('delivered_at', '>=', now()->subDays(30))
            ->get();

        return $this->success([
            'available_balance' => (float) $driver->available_balance,
            'pending_balance' => (float) $driver->pending_balance,
            'total_earnings' => (float) $driver->total_earnings,
            'total_deliveries' => $driver->total_deliveries,
            'completed_deliveries' => $driver->completed_deliveries,
            'last_30_days' => [
                'earnings' => (float) $deliveries->sum('driver_earning'),
                'deliveries' => $deliveries->count(),
            ],
            'driver' => DriverResource::make($driver),
        ]);
    }
}
