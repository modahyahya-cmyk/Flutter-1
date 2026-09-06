<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Video;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Video */
class VideoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vendor_id' => $this->vendor_id,
            'product_id' => $this->product_id,
            'title' => $this->title,
            'description' => $this->description,
            'video_url' => $this->video_url,
            'thumbnail_url' => $this->thumbnail_url,
            'cover_url' => $this->cover_url,
            'status' => $this->status,
            'duration_seconds' => $this->duration_seconds,
            'views_count' => $this->views_count,
            'likes_count' => $this->likes_count,
            'shares_count' => $this->shares_count,
            'is_active' => $this->is_active,
            'published_at' => $this->published_at?->toIso8601String(),
            'vendor' => $this->whenLoaded('vendor', fn () => VendorResource::make($this->vendor)),
            'product' => $this->whenLoaded('product', fn () => ProductResource::make($this->product)),
        ];
    }
}
