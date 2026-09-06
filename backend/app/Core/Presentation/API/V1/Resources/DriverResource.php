<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Driver;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Driver */
class DriverResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'user_id' => $this->user_id,
            'vehicle_type' => $this->vehicle_type,
            'vehicle_plate' => $this->vehicle_plate,
            'vehicle_color' => $this->vehicle_color,
            'status' => $this->status,
            'rejection_reason' => $this->rejection_reason,
            'is_online' => $this->is_online,
            'is_available' => $this->is_available,
            'latitude' => $this->latitude !== null ? (float) $this->latitude : null,
            'longitude' => $this->longitude !== null ? (float) $this->longitude : null,
            'last_location_at' => $this->last_location_at?->toIso8601String(),
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'total_earnings' => (float) $this->total_earnings,
            'pending_balance' => (float) $this->pending_balance,
            'available_balance' => (float) $this->available_balance,
            'total_deliveries' => $this->total_deliveries,
            'completed_deliveries' => $this->completed_deliveries,
            'is_verified' => $this->is_verified,
            'approved_at' => $this->approved_at?->toIso8601String(),
            'user' => $this->whenLoaded('user', fn () => UserResource::make($this->user)),
        ];
    }
}
