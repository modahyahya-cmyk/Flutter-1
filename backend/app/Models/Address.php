<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Address extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'user_id', 'label', 'recipient_name', 'recipient_phone',
        'address_line_1', 'address_line_2', 'city', 'state', 'country',
        'postal_code', 'latitude', 'longitude', 'landmark', 'instructions',
        'type', 'is_default',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'is_default' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}
