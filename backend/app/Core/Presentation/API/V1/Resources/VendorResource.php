<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Vendor;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Vendor */
class VendorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'user_id' => $this->user_id,
            'business_name' => $this->business_name,
            'slug' => $this->slug,
            'description' => $this->description,
            'business_email' => $this->business_email,
            'business_phone' => $this->business_phone,
            'logo' => $this->logo,
            'banner' => $this->banner,
            'status' => $this->status,
            'rejection_reason' => $this->rejection_reason,
            'is_verified' => $this->is_verified,
            'is_featured' => $this->is_featured,
            'accepts_orders' => $this->accepts_orders,
            'rating' => (float) $this->rating,
            'total_reviews' => $this->total_reviews,
            'total_orders' => $this->total_orders,
            'commission_rate' => (float) $this->commission_rate,
            'total_earnings' => (float) $this->total_earnings,
            'pending_balance' => (float) $this->pending_balance,
            'available_balance' => (float) $this->available_balance,
            'min_order_amount' => (float) $this->min_order_amount,
            'delivery_radius_km' => (float) $this->delivery_radius_km,
            'preparation_time_minutes' => $this->preparation_time_minutes,
            'operating_hours' => $this->operating_hours,
            'approved_at' => $this->approved_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'user' => $this->whenLoaded('user', fn () => UserResource::make($this->user)),
            'branches' => BranchResource::collection($this->whenLoaded('branches')),
            'products_count' => $this->whenCounted('products'),
        ];
    }
}
