<?php

namespace App\Core\Presentation\API\V1\Controllers\Vendor;

use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Requests\Product\CreateProductRequest;
use App\Core\Presentation\API\V1\Requests\Product\UpdateProductRequest;
use App\Core\Presentation\API\V1\Resources\ProductResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ProductManagementController extends BaseController
{
    public function __construct(
        private ProductRepositoryInterface $products,
        private VendorRepositoryInterface $vendors,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            ProductResource::collection($this->products->findByVendor($vendor->id, min($perPage, 100)))
        );
    }

    public function store(CreateProductRequest $request): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $data = $request->validated();
        $data['vendor_id'] = $vendor->id;
        $data['slug'] = $data['slug'] ?? Str::slug($data['name']).'-'.Str::random(6);
        $data['status'] = $data['status'] ?? 'active';

        $product = $this->products->create($data);

        return $this->success(ProductResource::make($product), 'Product created.', 201);
    }

    public function update(UpdateProductRequest $request, int $id): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $product = $this->products->findById($id);

        abort_if($product === null || $product->vendor_id !== $vendor->id, 404, 'Product not found.');

        $product = $this->products->update($product, $request->validated());

        return $this->success(ProductResource::make($product), 'Product updated.');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $product = $this->products->findById($id);

        abort_if($product === null || $product->vendor_id !== $vendor->id, 404, 'Product not found.');

        $this->products->delete($product);

        return $this->success(null, 'Product deleted.');
    }

    public function toggleActive(Request $request, int $id): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $product = $this->products->findById($id);

        abort_if($product === null || $product->vendor_id !== $vendor->id, 404, 'Product not found.');

        $newStatus = $product->status === 'active' ? 'inactive' : 'active';
        $product = $this->products->update($product, ['status' => $newStatus]);

        return $this->success(ProductResource::make($product), 'Product toggled.');
    }

    private function vendorFrom(Request $request)
    {
        $user = $request->attributes->get('user');
        $vendor = $this->vendors->findByUserId($user->id);

        abort_if($vendor === null, 403, 'No vendor profile linked to this account.');

        return $vendor;
    }
}
