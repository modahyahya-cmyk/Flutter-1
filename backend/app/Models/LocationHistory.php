<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LocationHistory extends Model
{
    use HasFactory, HasUuid;

    protected $table = 'location_history';

    protected $fillable = [
        'uuid', 'driver_id', 'latitude', 'longitude', 'accuracy',
        'speed_kmh', 'heading_deg', 'altitude_m', 'captured_at',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'driver_id' => 'integer',
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'accuracy' => 'decimal:2',
            'speed_kmh' => 'float',
            'heading_deg' => 'float',
            'altitude_m' => 'decimal:2',
            'captured_at' => 'datetime',
        ];
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }
}
