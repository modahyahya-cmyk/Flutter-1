<?php

namespace App\Core\Presentation\API\V1\Controllers\Admin;

use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\DriverResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DriverApprovalController extends BaseController
{
    public function __construct(private DriverRepositoryInterface $drivers)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            DriverResource::collection($this->drivers->paginate(min($perPage, 100), $request->query('status')))
        );
    }

    public function approve(int $id): JsonResponse
    {
        $driver = $this->drivers->findById($id);
        abort_if($driver === null, 404, 'Driver not found.');

        $driver = $this->drivers->approve($driver);

        return $this->success(DriverResource::make($driver), 'Driver approved.');
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate(['reason' => ['required', 'string', 'max:1000']]);

        $driver = $this->drivers->findById($id);
        abort_if($driver === null, 404, 'Driver not found.');

        $driver = $this->drivers->reject($driver, $validated['reason']);

        return $this->success(DriverResource::make($driver), 'Driver rejected.');
    }
}
