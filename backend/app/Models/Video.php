<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Video extends Model
{
    use HasFactory;

    protected $fillable = [
        'vendor_id', 'product_id', 'title', 'description', 'video_url',
        'thumbnail_url', 'cover_url', 'status', 'duration_seconds',
        'views_count', 'likes_count', 'shares_count', 'comments_count',
        'video_quality', 'video_size_bytes', 'is_active', 'published_at',
        'metadata',
    ];

    protected function casts(): array
    {
        return [
            'duration_seconds' => 'integer',
            'views_count' => 'integer',
            'likes_count' => 'integer',
            'shares_count' => 'integer',
            'comments_count' => 'integer',
            'video_size_bytes' => 'integer',
            'is_active' => 'boolean',
            'published_at' => 'datetime',
            'metadata' => 'array',
        ];
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function isPublished(): bool
    {
        return $this->status === 'published' && $this->is_active;
    }
}
