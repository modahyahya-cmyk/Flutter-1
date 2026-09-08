<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Order */
class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'order_number' => $this->order_number,
            'customer_id' => $this->customer_id,
            'vendor_id' => $this->vendor_id,
            'driver_id' => $this->driver_id,
            'branch_id' => $this->branch_id,
            'order_type' => $this->order_type,
            'subtotal' => (float) $this->subtotal,
            'tax_amount' => (float) $this->tax_amount,
            'delivery_fee' => (float) $this->delivery_fee,
            'discount_amount' => (float) $this->discount_amount,
            'tip_amount' => (float) $this->tip_amount,
            'total_amount' => (float) $this->total_amount,
            'commission_amount' => (float) $this->commission_amount,
            'vendor_earnings' => (float) $this->vendor_earnings,
            'status' => $this->status,
            'payment_status' => $this->payment_status,
            'payment_method' => $this->payment_method,
            'delivery_address' => $this->delivery_address,
            'customer_notes' => $this->customer_notes,
            'delivery_latitude' => $this->delivery_latitude !== null ? (float) $this->delivery_latitude : null,
            'delivery_longitude' => $this->delivery_longitude !== null ? (float) $this->delivery_longitude : null,
            'delivery_distance_km' => $this->delivery_distance_km !== null ? (float) $this->delivery_distance_km : null,
            'confirmed_at' => $this->confirmed_at?->toIso8601String(),
            'preparing_at' => $this->preparing_at?->toIso8601String(),
            'ready_at' => $this->ready_at?->toIso8601String(),
            'picked_up_at' => $this->picked_up_at?->toIso8601String(),
            'delivered_at' => $this->delivered_at?->toIso8601String(),
            'cancelled_at' => $this->cancelled_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
            'customer' => $this->whenLoaded('customer', fn () => UserResource::make($this->customer)),
            'vendor' => $this->whenLoaded('vendor', fn () => VendorResource::make($this->vendor)),
            'driver' => $this->whenLoaded('driver', fn () => DriverResource::make($this->driver)),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
        ];
    }
}
