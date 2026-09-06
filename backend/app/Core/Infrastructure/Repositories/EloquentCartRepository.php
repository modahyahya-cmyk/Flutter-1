<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\CartRepositoryInterface;
use App\Models\Cart;
use App\Models\CartItem;

class EloquentCartRepository implements CartRepositoryInterface
{
    public function findById(int $id): ?Cart
    {
        return Cart::with('items.product', 'items.variant')->find($id);
    }

    public function findByUser(int $userId): ?Cart
    {
        return Cart::where('user_id', $userId)
            ->with('items.product', 'items.variant')
            ->first();
    }

    public function findBySession(string $sessionId): ?Cart
    {
        return Cart::where('session_id', $sessionId)
            ->with('items.product', 'items.variant')
            ->first();
    }

    public function findOrCreateForUser(int $userId): Cart
    {
        return Cart::firstOrCreate(['user_id' => $userId]);
    }

    public function findOrCreateForSession(string $sessionId): Cart
    {
        return Cart::firstOrCreate(['session_id' => $sessionId]);
    }

    public function addItem(Cart $cart, array $data): CartItem
    {
        $item = $cart->items()->where('product_id', $data['product_id'])
            ->when(isset($data['variant_id']), fn ($q) => $q->where('variant_id', $data['variant_id']))
            ->first();

        if ($item) {
            $item->update([
                'quantity' => $item->quantity + $data['quantity'],
                'total_amount' => $item->unit_price * ($item->quantity + $data['quantity']),
            ]);
        } else {
            $item = $cart->items()->create([
                'product_id' => $data['product_id'],
                'variant_id' => $data['variant_id'] ?? null,
                'quantity' => $data['quantity'],
                'unit_price' => $data['unit_price'],
                'unit_cost' => $data['unit_cost'] ?? 0,
                'total_amount' => $data['unit_price'] * $data['quantity'],
                'options' => $data['options'] ?? null,
            ]);
        }

        $cart->recalculateTotals();

        return $item;
    }

    public function updateItem(CartItem $item, array $data): CartItem
    {
        $item->update($data);
        $item->cart->recalculateTotals();

        return $item->fresh();
    }

    public function removeItem(CartItem $item): bool
    {
        $cart = $item->cart;
        $result = (bool) $item->delete();
        $cart->recalculateTotals();

        return $result;
    }

    public function clear(Cart $cart): void
    {
        $cart->items()->delete();
        $cart->recalculateTotals();
    }

    public function countItems(Cart $cart): int
    {
        return (int) $cart->items()->sum('quantity');
    }
}
