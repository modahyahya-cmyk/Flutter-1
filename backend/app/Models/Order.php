<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $fillable = [
        'uuid', 'order_number', 'idempotency_key', 'customer_id', 'vendor_id',
        'branch_id', 'driver_id', 'order_type',
        'status', 'payment_status',
        'subtotal', 'tax_amount', 'delivery_fee', 'discount_amount',
        'tip_amount', 'total_amount', 'commission_amount', 'vendor_earnings',
        'delivery_address', 'delivery_latitude', 'delivery_longitude',
        'delivery_phone', 'delivery_notes', 'delivery_distance_km',
        'confirmed_at', 'preparing_at', 'ready_at', 'picked_up_at',
        'delivered_at', 'cancelled_at', 'scheduled_for',
        'customer_notes', 'vendor_notes', 'cancellation_reason',
        'payment_method', 'payment_transaction_id',
        'customer_rating', 'customer_review', 'reviewed_at',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'subtotal' => 'decimal:2',
            'tax_amount' => 'decimal:2',
            'delivery_fee' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'tip_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'commission_amount' => 'decimal:2',
            'vendor_earnings' => 'decimal:2',
            'delivery_latitude' => 'decimal:8',
            'delivery_longitude' => 'decimal:8',
            'delivery_distance_km' => 'decimal:2',
            'confirmed_at' => 'datetime',
            'preparing_at' => 'datetime',
            'ready_at' => 'datetime',
            'picked_up_at' => 'datetime',
            'delivered_at' => 'datetime',
            'cancelled_at' => 'datetime',
            'scheduled_for' => 'datetime',
            'reviewed_at' => 'datetime',
            'customer_rating' => 'integer',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function deliveries(): HasMany
    {
        return $this->hasMany(Delivery::class);
    }
}
