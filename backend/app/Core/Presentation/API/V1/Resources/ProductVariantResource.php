<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin ProductVariant */
class ProductVariantResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'name' => $this->name,
            'sku' => $this->sku,
            'barcode' => $this->barcode,
            'price' => $this->price !== null ? (float) $this->price : null,
            'compare_at_price' => $this->compare_at_price !== null ? (float) $this->compare_at_price : null,
            'stock_quantity' => $this->stock_quantity,
            'attributes' => $this->attributes ?? [],
            'image' => $this->image,
            'is_default' => $this->is_default,
            'is_active' => $this->is_active,
        ];
    }
}
