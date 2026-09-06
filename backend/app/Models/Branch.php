<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Branch extends Model
{
    use HasFactory, HasUuid, SoftDeletes;

    protected $fillable = [
        'uuid', 'vendor_id', 'name', 'slug', 'phone', 'email',
        'address_line_1', 'address_line_2', 'city', 'state', 'country',
        'postal_code', 'latitude', 'longitude', 'is_primary', 'is_active',
        'operating_hours', 'preparation_time_minutes', 'delivery_radius_km',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'is_primary' => 'boolean',
            'is_active' => 'boolean',
            'operating_hours' => 'array',
            'preparation_time_minutes' => 'integer',
            'delivery_radius_km' => 'decimal:2',
        ];
    }

    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class);
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function isOpenNow(): bool
    {
        $hours = $this->operating_hours ?? [];
        if (empty($hours)) {
            return true;
        }

        $now = now()->format('H:i');
        $day = strtolower(now()->format('l')); // monday..sunday
        $today = $hours[$day] ?? null;

        if ($today === null) {
            return false;
        }

        $open = $today['open'] ?? null;
        $close = $today['close'] ?? null;

        if ($open === null || $close === null) {
            return false;
        }

        return $now >= $open && $now <= $close;
    }
}
