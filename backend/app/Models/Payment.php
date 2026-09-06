<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'payment_reference', 'order_id', 'user_id', 'vendor_id',
        'provider', 'provider_reference', 'amount', 'fee', 'net_amount',
        'currency_rate', 'currency', 'method', 'status', 'error_message',
        'refunded_amount', 'metadata', 'webhook_payload',
        'paid_at', 'refunded_at',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'amount' => 'decimal:2',
            'fee' => 'decimal:2',
            'net_amount' => 'decimal:2',
            'currency_rate' => 'decimal:6',
            'refunded_amount' => 'decimal:2',
            'metadata' => 'array',
            'webhook_payload' => 'array',
            'paid_at' => 'datetime',
            'refunded_at' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }
}
