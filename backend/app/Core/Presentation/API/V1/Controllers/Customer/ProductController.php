<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\ProductResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends BaseController
{
    public function __construct(private ProductRepositoryInterface $products)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only([
            'category_id', 'vendor_id', 'min_price', 'max_price',
            'sort', 'lat', 'lng', 'per_page',
        ]);

        $perPage = (int) ($filters['per_page'] ?? 15);

        $products = $this->products->paginate(min($perPage, 100), $filters);

        return $this->paginated(ProductResource::collection($products));
    }

    public function featured(Request $request): JsonResponse
    {
        $limit = (int) $request->query('limit', 10);

        return $this->success(
            ProductResource::collection($this->products->findFeatured(min($limit, 50)))
        );
    }

    public function bestSellers(Request $request): JsonResponse
    {
        $limit = (int) $request->query('limit', 10);

        return $this->success(
            ProductResource::collection($this->products->findBestSellers(min($limit, 50)))
        );
    }

    public function search(Request $request): JsonResponse
    {
        $request->validate(['q' => ['required', 'string', 'max:255']]);
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            ProductResource::collection($this->products->search($request->query('q'), min($perPage, 100)))
        );
    }

    public function show(string $slugOrId): JsonResponse
    {
        $product = is_numeric($slugOrId)
            ? $this->products->findById((int) $slugOrId)
            : $this->products->findBySlug($slugOrId);

        abort_if($product === null, 404, 'Product not found.');

        return $this->success(ProductResource::make($product));
    }
}
