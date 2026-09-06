<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProductVariant extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'product_id', 'name', 'sku', 'barcode',
        'price', 'compare_at_price', 'cost_price',
        'stock_quantity', 'track_inventory', 'options',
        'image', 'is_active', 'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'price' => 'decimal:2',
            'compare_at_price' => 'decimal:2',
            'cost_price' => 'decimal:2',
            'stock_quantity' => 'integer',
            'track_inventory' => 'boolean',
            'options' => 'array',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
