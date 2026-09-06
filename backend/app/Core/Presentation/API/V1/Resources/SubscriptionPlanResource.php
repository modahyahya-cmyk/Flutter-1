<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\SubscriptionPlan;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin SubscriptionPlan */
class SubscriptionPlanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'description' => $this->description,
            'price' => (float) $this->price,
            'billing_cycle' => $this->billing_cycle,
            'duration_days' => $this->duration_days,
            'featured' => $this->featured,
            'features' => $this->features ?? [],
            'commission_rate' => $this->commission_rate !== null ? (float) $this->commission_rate : null,
            'is_active' => $this->is_active,
            'sort_order' => $this->sort_order,
        ];
    }
}
