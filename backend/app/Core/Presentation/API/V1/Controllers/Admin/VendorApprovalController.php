<?php

namespace App\Core\Presentation\API\V1\Controllers\Admin;

use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\VendorResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorApprovalController extends BaseController
{
    public function __construct(private VendorRepositoryInterface $vendors)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            VendorResource::collection($this->vendors->paginate(min($perPage, 100), null, $request->query('status')))
        );
    }

    public function approve(int $id): JsonResponse
    {
        $vendor = $this->vendors->findById($id);
        abort_if($vendor === null, 404, 'Vendor not found.');

        $vendor = $this->vendors->approve($vendor);

        return $this->success(VendorResource::make($vendor), 'Vendor approved.');
    }

    public function reject(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate(['reason' => ['required', 'string', 'max:1000']]);

        $vendor = $this->vendors->findById($id);
        abort_if($vendor === null, 404, 'Vendor not found.');

        $vendor = $this->vendors->reject($vendor, $validated['reason']);

        return $this->success(VendorResource::make($vendor), 'Vendor rejected.');
    }

    public function suspend(int $id): JsonResponse
    {
        $vendor = $this->vendors->findById($id);
        abort_if($vendor === null, 404, 'Vendor not found.');

        $vendor = $this->vendors->suspend($vendor);

        return $this->success(VendorResource::make($vendor), 'Vendor suspended.');
    }
}
