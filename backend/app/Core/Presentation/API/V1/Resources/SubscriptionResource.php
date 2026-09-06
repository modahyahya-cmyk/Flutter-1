<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Subscription;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Subscription */
class SubscriptionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'plan_id' => $this->plan_id,
            'user_id' => $this->user_id,
            'vendor_id' => $this->vendor_id,
            'provider' => $this->provider,
            'amount' => (float) $this->amount,
            'currency' => $this->currency,
            'status' => $this->status,
            'starts_at' => $this->starts_at?->toIso8601String(),
            'ends_at' => $this->ends_at?->toIso8601String(),
            'cancelled_at' => $this->cancelled_at?->toIso8601String(),
            'last_billed_at' => $this->last_billed_at?->toIso8601String(),
            'next_billing_at' => $this->next_billing_at?->toIso8601String(),
            'created_at' => $this->created_at?->toIso8601String(),
            'plan' => $this->whenLoaded('plan', fn () => SubscriptionPlanResource::make($this->plan)),
        ];
    }
}
