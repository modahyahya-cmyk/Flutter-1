<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Product */
class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $symbol = config('app_settings.localization.currency_symbol', '$');

        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'vendor_id' => $this->vendor_id,
            'category_id' => $this->category_id,
            'branch_id' => $this->branch_id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'short_description' => $this->short_description,
            'price' => (float) $this->price,
            'formatted_price' => $symbol.number_format((float) $this->price, 2),
            'compare_at_price' => $this->compare_at_price !== null ? (float) $this->compare_at_price : null,
            'cost_price' => $this->cost_price !== null ? (float) $this->cost_price : null,
            'is_taxable' => $this->is_taxable,
            'tax_rate' => (float) $this->tax_rate,
            'inventory_type' => $this->inventory_type,
            'stock_quantity' => $this->stock_quantity,
            'low_stock_threshold' => $this->low_stock_threshold,
            'track_inventory' => $this->track_inventory,
            'allow_backorder' => $this->allow_backorder,
            'status' => $this->status,
            'is_featured' => $this->is_featured,
            'is_new_arrival' => $this->is_new_arrival,
            'is_bestseller' => $this->is_bestseller,
            'thumbnail' => $this->thumbnail,
            'images' => $this->images ?? [],
            'unit' => $this->unit,
            'weight' => $this->weight,
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'total_sales' => $this->total_sales,
            'view_count' => $this->view_count,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'vendor' => $this->whenLoaded('vendor', fn () => VendorResource::make($this->vendor)),
            'category' => $this->whenLoaded('category', fn () => [
                'id' => $this->category->id,
                'name' => $this->category->name,
                'slug' => $this->category->slug,
            ]),
            'variants' => ProductVariantResource::collection($this->whenLoaded('variants')),
        ];
    }
}
