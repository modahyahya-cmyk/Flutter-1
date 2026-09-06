<?php

namespace App\Core\Domain\Repositories;

use App\Models\Video;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface VideoRepositoryInterface
{
    public function findById(int $id): ?Video;

    public function create(array $data): Video;

    public function update(Video $video, array $data): Video;

    public function delete(Video $video): bool;

    public function paginatePublished(int $perPage = 10): LengthAwarePaginator;

    public function paginateForVendor(int $vendorId, int $perPage = 15): LengthAwarePaginator;

    public function incrementViews(Video $video): void;

    public function toggleLike(Video $video, bool $liked): void;

    public function findByProduct(int $productId): array;
}
