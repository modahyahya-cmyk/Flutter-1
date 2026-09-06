<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Delivery;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Delivery */
class DeliveryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_id' => $this->order_id,
            'driver_id' => $this->driver_id,
            'pickup_latitude' => $this->pickup_latitude !== null ? (float) $this->pickup_latitude : null,
            'pickup_longitude' => $this->pickup_longitude !== null ? (float) $this->pickup_longitude : null,
            'dropoff_latitude' => $this->dropoff_latitude !== null ? (float) $this->dropoff_latitude : null,
            'dropoff_longitude' => $this->dropoff_longitude !== null ? (float) $this->dropoff_longitude : null,
            'distance_km' => (float) $this->distance_km,
            'fee' => (float) $this->fee,
            'driver_earning' => (float) $this->driver_earning,
            'status' => $this->status,
            'assigned_at' => $this->assigned_at?->toIso8601String(),
            'picked_up_at' => $this->picked_up_at?->toIso8601String(),
            'delivered_at' => $this->delivered_at?->toIso8601String(),
            'cancelled_at' => $this->cancelled_at?->toIso8601String(),
            'order' => $this->whenLoaded('order', fn () => OrderResource::make($this->order)),
        ];
    }
}
