<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\VideoRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\VideoResource;
use App\Models\Video;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VideoController extends BaseController
{
    public function __construct(private VideoRepositoryInterface $videos)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->query('per_page', 10);

        return $this->paginated(
            VideoResource::collection($this->videos->paginatePublished(min($perPage, 30)))
        );
    }

    public function show(int $id): JsonResponse
    {
        $video = $this->videos->findById($id);

        abort_if($video === null || ! $video->isPublished(), 404, 'Video not found.');

        $this->videos->incrementViews($video);

        return $this->success(VideoResource::make($video));
    }

    public function like(Request $request, int $id): JsonResponse
    {
        /** @var Video $video */
        $video = $this->videos->findById($id);

        abort_if($video === null, 404, 'Video not found.');

        $liked = (bool) $request->boolean('liked', true);
        $this->videos->toggleLike($video, $liked);

        return $this->success([
            'likes_count' => $video->fresh()->likes_count,
        ]);
    }
}
