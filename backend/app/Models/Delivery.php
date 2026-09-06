<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Delivery extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'order_id', 'driver_id',
        'pickup_latitude', 'pickup_longitude',
        'dropoff_latitude', 'dropoff_longitude',
        'distance_km', 'duration_minutes', 'fee', 'driver_earning',
        'tip_amount', 'status', 'assigned_at', 'picked_up_at',
        'delivered_at', 'cancelled_at', 'proof_of_delivery', 'is_confirmed',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'pickup_latitude' => 'decimal:8',
            'pickup_longitude' => 'decimal:8',
            'dropoff_latitude' => 'decimal:8',
            'dropoff_longitude' => 'decimal:8',
            'distance_km' => 'decimal:2',
            'duration_minutes' => 'decimal:2',
            'fee' => 'decimal:2',
            'driver_earning' => 'decimal:2',
            'tip_amount' => 'decimal:2',
            'is_confirmed' => 'boolean',
            'assigned_at' => 'datetime',
            'picked_up_at' => 'datetime',
            'delivered_at' => 'datetime',
            'cancelled_at' => 'datetime',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }
}
