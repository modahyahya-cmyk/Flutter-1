<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Models\Product;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentProductRepository implements ProductRepositoryInterface
{
    public function findById(int $id): ?Product
    {
        return Product::with(['vendor', 'category', 'variants'])->find($id);
    }

    public function findBySlug(string $slug): ?Product
    {
        return Product::with(['vendor', 'category', 'variants'])
            ->where('slug', $slug)
            ->first();
    }

    public function create(array $data): Product
    {
        return Product::create($data);
    }

    public function update(Product $product, array $data): Product
    {
        $product->update($data);

        return $product->fresh();
    }

    public function delete(Product $product): bool
    {
        return (bool) $product->delete();
    }

    public function paginate(int $perPage = 15, array $filters = []): LengthAwarePaginator
    {
        $query = Product::query()
            ->where('status', 'active')
            ->with(['vendor', 'category']);

        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['vendor_id'])) {
            $query->where('vendor_id', $filters['vendor_id']);
        }

        if (isset($filters['min_price'])) {
            $query->where('price', '>=', $filters['min_price']);
        }

        if (isset($filters['max_price'])) {
            $query->where('price', '<=', $filters['max_price']);
        }

        match ($filters['sort'] ?? null) {
            'price_asc' => $query->orderBy('price', 'asc'),
            'price_desc' => $query->orderBy('price', 'desc'),
            'rating' => $query->orderByDesc('rating'),
            'best_selling' => $query->orderByDesc('total_sales'),
            default => $query->orderByDesc('created_at'),
        };

        return $query->paginate($perPage);
    }

    public function findFeatured(int $limit = 10): array
    {
        return Product::where('status', 'active')
            ->where('is_featured', true)
            ->with('vendor')
            ->latest()
            ->limit($limit)
            ->get()
            ->all();
    }

    public function findBestSellers(int $limit = 10): array
    {
        return Product::where('status', 'active')
            ->with('vendor')
            ->orderByDesc('total_sales')
            ->limit($limit)
            ->get()
            ->all();
    }

    public function nearest(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        return $this->paginate($perPage, $filters);
    }

    public function search(string $term, int $perPage = 15): LengthAwarePaginator
    {
        return Product::where('status', 'active')
            ->where(function ($q) use ($term) {
                $q->where('name', 'like', "%{$term}%")
                    ->orWhere('description', 'like', "%{$term}%")
                    ->orWhereHas('vendor', fn ($v) => $v->where('business_name', 'like', "%{$term}%"));
            })
            ->with(['vendor', 'category'])
            ->paginate($perPage);
    }

    public function findByVendor(int $vendorId, int $perPage = 15): LengthAwarePaginator
    {
        return Product::where('vendor_id', $vendorId)
            ->with(['category', 'variants'])
            ->latest()
            ->paginate($perPage);
    }

    public function decrementStock(Product $product, int $quantity): void
    {
        $product->decrement('stock_quantity', $quantity);
    }

    public function incrementSales(Product $product, int $quantity): void
    {
        $product->increment('total_sales', $quantity);
    }

    public function countActiveByVendor(int $vendorId): int
    {
        return Product::where('vendor_id', $vendorId)
            ->where('status', 'active')
            ->count();
    }
}
