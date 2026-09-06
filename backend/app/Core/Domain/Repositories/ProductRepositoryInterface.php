<?php

namespace App\Core\Domain\Repositories;

use App\Models\Product;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ProductRepositoryInterface
{
    public function findById(int $id): ?Product;

    public function findBySlug(string $slug): ?Product;

    public function create(array $data): Product;

    public function update(Product $product, array $data): Product;

    public function delete(Product $product): bool;

    public function paginate(int $perPage = 15, array $filters = []): LengthAwarePaginator;

    public function findFeatured(int $limit = 10): array;

    public function findBestSellers(int $limit = 10): array;

    public function nearest(array $filters = [], int $perPage = 15): LengthAwarePaginator;

    public function search(string $term, int $perPage = 15): LengthAwarePaginator;

    public function findByVendor(int $vendorId, int $perPage = 15): LengthAwarePaginator;

    public function decrementStock(Product $product, int $quantity): void;

    public function incrementSales(Product $product, int $quantity): void;

    public function countActiveByVendor(int $vendorId): int;
}
