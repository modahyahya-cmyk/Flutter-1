<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Driver extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $fillable = [
        'uuid', 'user_id', 'vehicle_type', 'vehicle_plate', 'vehicle_color',
        'license_number', 'license_image', 'id_card', 'national_id',
        'license_expiry', 'status', 'rejection_reason', 'is_online',
        'is_available', 'latitude', 'longitude', 'last_location_at',
        'rating', 'total_reviews', 'total_earnings', 'pending_balance',
        'available_balance', 'total_deliveries', 'completed_deliveries',
        'is_verified', 'approved_at', 'approved_by',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'rating' => 'decimal:2',
            'total_reviews' => 'integer',
            'total_earnings' => 'decimal:2',
            'pending_balance' => 'decimal:2',
            'available_balance' => 'decimal:2',
            'total_deliveries' => 'integer',
            'completed_deliveries' => 'integer',
            'is_online' => 'boolean',
            'is_available' => 'boolean',
            'is_verified' => 'boolean',
            'license_expiry' => 'date',
            'last_location_at' => 'datetime',
            'approved_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function deliveries(): HasMany
    {
        return $this->hasMany(Delivery::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function locations(): HasMany
    {
        return $this->hasMany(LocationHistory::class);
    }

    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }
}
