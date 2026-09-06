<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $fillable = [
        'uuid', 'vendor_id', 'category_id', 'branch_id', 'name', 'slug',
        'description', 'short_description', 'sku', 'barcode',
        'price', 'compare_at_price', 'cost_price', 'is_taxable', 'tax_rate',
        'inventory_type', 'stock_quantity', 'low_stock_threshold',
        'track_inventory', 'allow_backorder',
        'thumbnail', 'images', 'video_id',
        'unit', 'weight', 'dimensions',
        'status', 'is_featured', 'is_new_arrival', 'is_bestseller',
        'rating', 'total_reviews', 'total_sales', 'view_count',
        'meta_title', 'meta_description', 'meta_keywords',
        'available_from', 'available_until',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'price' => 'decimal:2',
            'compare_at_price' => 'decimal:2',
            'cost_price' => 'decimal:2',
            'is_taxable' => 'boolean',
            'tax_rate' => 'decimal:2',
            'stock_quantity' => 'integer',
            'low_stock_threshold' => 'integer',
            'track_inventory' => 'boolean',
            'allow_backorder' => 'boolean',
            'images' => 'array',
            'weight' => 'decimal:2',
            'dimensions' => 'array',
            'is_featured' => 'boolean',
            'is_new_arrival' => 'boolean',
            'is_bestseller' => 'boolean',
            'rating' => 'decimal:2',
            'total_reviews' => 'integer',
            'total_sales' => 'integer',
            'view_count' => 'integer',
            'available_from' => 'datetime',
            'available_until' => 'datetime',
        ];
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function video(): BelongsTo
    {
        return $this->belongsTo(Video::class);
    }

    public function variants(): HasMany
    {
        return $this->hasMany(ProductVariant::class);
    }

    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function videos(): HasMany
    {
        return $this->hasMany(Video::class);
    }

    public function cartItems(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function getFormattedPriceAttribute(): string
    {
        $symbol = config('app_settings.localization.currency_symbol', '$');

        return $symbol.number_format((float) $this->price, 2);
    }
}
