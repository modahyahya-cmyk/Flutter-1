<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SubscriptionPlan extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'name', 'code', 'description', 'price', 'billing_cycle',
        'duration_days', 'discounted_price', 'featured', 'features',
        'commission_rate', 'is_active', 'sort_order',
        'meta_title', 'meta_description',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'price' => 'decimal:2',
            'discounted_price' => 'decimal:2',
            'duration_days' => 'integer',
            'featured' => 'boolean',
            'features' => 'array',
            'commission_rate' => 'decimal:2',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }
}
