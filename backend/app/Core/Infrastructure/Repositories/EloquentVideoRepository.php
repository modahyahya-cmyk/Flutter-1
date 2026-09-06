<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\VideoRepositoryInterface;
use App\Models\Video;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentVideoRepository implements VideoRepositoryInterface
{
    public function findById(int $id): ?Video
    {
        return Video::with(['vendor', 'product'])->find($id);
    }

    public function create(array $data): Video
    {
        return Video::create($data);
    }

    public function update(Video $video, array $data): Video
    {
        $video->update($data);

        return $video->fresh();
    }

    public function delete(Video $video): bool
    {
        return (bool) $video->delete();
    }

    public function paginatePublished(int $perPage = 10): LengthAwarePaginator
    {
        return Video::where('status', 'published')
            ->where('is_active', true)
            ->with(['vendor', 'product'])
            ->latest()
            ->paginate($perPage);
    }

    public function paginateForVendor(int $vendorId, int $perPage = 15): LengthAwarePaginator
    {
        return Video::where('vendor_id', $vendorId)
            ->with('product')
            ->latest()
            ->paginate($perPage);
    }

    public function incrementViews(Video $video): void
    {
        $video->increment('views_count');
    }

    public function toggleLike(Video $video, bool $liked): void
    {
        if ($liked) {
            $video->increment('likes_count');
        } else {
            $video->decrement('likes_count');
        }
    }

    public function findByProduct(int $productId): array
    {
        return Video::where('product_id', $productId)
            ->where('status', 'published')
            ->get()
            ->all();
    }
}
