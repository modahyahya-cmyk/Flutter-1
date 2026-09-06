<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Subscription extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'plan_id', 'user_id', 'vendor_id', 'external_reference',
        'provider', 'amount', 'currency', 'status', 'starts_at', 'ends_at',
        'cancelled_at', 'last_billed_at', 'next_billing_at',
        'renewal_method', 'metadata',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'amount' => 'decimal:2',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'cancelled_at' => 'datetime',
            'last_billed_at' => 'datetime',
            'next_billing_at' => 'datetime',
            'metadata' => 'array',
        ];
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function isActive(): bool
    {
        return $this->status === 'active';
    }
}
