<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;

class Vendor extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $table = 'vendors';

    protected $fillable = [
        'uuid', 'user_id', 'business_name', 'slug', 'description',
        'business_email', 'business_phone', 'business_registration_number',
        'tax_id', 'logo', 'banner', 'status', 'rejection_reason',
        'approved_at', 'approved_by',
        'bank_name', 'account_holder_name', 'account_number',
        'routing_number', 'swift_code',
        'commission_rate', 'rating', 'total_reviews', 'total_orders',
        'total_earnings', 'pending_balance', 'available_balance',
        'operating_hours', 'is_featured', 'is_verified', 'accepts_orders',
        'auto_accept_orders', 'preparation_time_minutes', 'min_order_amount',
        'delivery_radius_km', 'meta_title', 'meta_description', 'meta_keywords',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'rating' => 'decimal:2',
            'total_reviews' => 'integer',
            'total_orders' => 'integer',
            'total_earnings' => 'decimal:2',
            'pending_balance' => 'decimal:2',
            'available_balance' => 'decimal:2',
            'commission_rate' => 'decimal:2',
            'operating_hours' => 'array',
            'is_featured' => 'boolean',
            'is_verified' => 'boolean',
            'accepts_orders' => 'boolean',
            'auto_accept_orders' => 'boolean',
            'preparation_time_minutes' => 'integer',
            'min_order_amount' => 'decimal:2',
            'delivery_radius_km' => 'decimal:2',
            'approved_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function branches(): HasMany
    {
        return $this->hasMany(Branch::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function videos(): HasMany
    {
        return $this->hasMany(Video::class);
    }

    public function subscription(): HasOne
    {
        return $this->hasOne(Subscription::class)->latestOfMany();
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class, 'vendor_id', 'id');
    }

    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }
}
