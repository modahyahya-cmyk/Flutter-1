<?php

namespace App\Core\Presentation\API\V1\Controllers\Vendor;

use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\BranchResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class BranchController extends BaseController
{
    public function __construct(private VendorRepositoryInterface $vendors)
    {
    }

    private function vendor(Request $request)
    {
        $user = $request->attributes->get('user');
        $vendor = $this->vendors->findByUserId($user->id);
        abort_if($vendor === null, 403, 'No vendor profile linked to this account.');

        return $vendor;
    }

    public function index(Request $request): JsonResponse
    {
        $vendor = $this->vendor($request);

        return $this->success(BranchResource::collection($vendor->load('branches')->branches));
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'phone' => ['nullable', 'string', 'max:20'],
            'opens_at' => ['nullable', 'date_format:H:i'],
            'closes_at' => ['nullable', 'date_format:H:i'],
            'is_primary' => ['nullable', 'boolean'],
        ]);

        $vendor = $this->vendor($request);
        $branch = $vendor->branches()->create($validated);

        return $this->success(BranchResource::make($branch), 'Branch created.', 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:500'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
            'phone' => ['nullable', 'string', 'max:20'],
            'opens_at' => ['nullable', 'date_format:H:i'],
            'closes_at' => ['nullable', 'date_format:H:i'],
            'status' => ['sometimes', Rule::in(['active', 'inactive'])],
        ]);

        $vendor = $this->vendor($request);
        $branch = $vendor->branches()->find($id);

        abort_if($branch === null, 404, 'Branch not found.');

        $branch->update($validated);

        return $this->success(BranchResource::make($branch), 'Branch updated.');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $vendor = $this->vendor($request);
        $branch = $vendor->branches()->find($id);

        abort_if($branch === null, 404, 'Branch not found.');

        $branch->delete();

        return $this->success(null, 'Branch deleted.');
    }
}
