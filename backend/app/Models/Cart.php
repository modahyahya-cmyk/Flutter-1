<?php

namespace App\Models;

use App\Models\Concerns\HasUuid;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cart extends Model
{
    use HasFactory, HasUuid;

    protected $fillable = [
        'uuid', 'user_id', 'session_id', 'subtotal', 'tax_amount',
        'total_amount', 'currency', 'metadata',
    ];

    protected function casts(): array
    {
        return [
            'uuid' => 'string',
            'subtotal' => 'decimal:2',
            'tax_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'metadata' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function recalculateTotals(): void
    {
        $subtotal = (float) $this->items()->sum('total_amount');
        $tax = round($subtotal * 0.05, 2);

        $this->subtotal = $subtotal;
        $this->tax_amount = $tax;
        $this->total_amount = round($subtotal + $tax, 2);
        $this->save();
    }
}
