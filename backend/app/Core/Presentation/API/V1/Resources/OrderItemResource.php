<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin OrderItem */
class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'variant_id' => $this->variant_id,
            'product_name' => $this->product_name,
            'variant_name' => $this->variant_name,
            'sku' => $this->sku,
            'image' => $this->image,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'total_amount' => (float) $this->total_amount,
            'commission_amount' => (float) $this->commission_amount,
            'vendor_earnings' => (float) $this->vendor_earnings,
            'options' => $this->options ?? [],
        ];
    }
}
