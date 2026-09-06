<?php

namespace App\Core\Presentation\API\V1\Resources;

use App\Models\Branch;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Branch */
class BranchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vendor_id' => $this->vendor_id,
            'name' => $this->name,
            'address' => $this->address,
            'latitude' => $this->latitude !== null ? (float) $this->latitude : null,
            'longitude' => $this->longitude !== null ? (float) $this->longitude : null,
            'phone' => $this->phone,
            'opens_at' => $this->opens_at?->format('H:i'),
            'closes_at' => $this->closes_at?->format('H:i'),
            'status' => $this->status,
            'is_primary' => $this->is_primary,
        ];
    }
}
