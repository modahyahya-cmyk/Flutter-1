<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Review extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'user_id', 'product_id', 'vendor_id', 'order_id',
        'rating', 'comment', 'media', 'review_type', 'is_approved',
        'reply', 'replied_at', 'is_edited',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'rating' => 'integer',
            'media' => 'array',
            'is_approved' => 'boolean',
            'is_edited' => 'boolean',
            'replied_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
