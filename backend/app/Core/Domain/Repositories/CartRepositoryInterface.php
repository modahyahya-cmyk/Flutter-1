<?php

namespace App\Core\Domain\Repositories;

use App\Models\Cart;
use App\Models\CartItem;

interface CartRepositoryInterface
{
    public function findById(int $id): ?Cart;

    public function findByUser(int $userId): ?Cart;

    public function findBySession(string $sessionId): ?Cart;

    public function findOrCreateForUser(int $userId): Cart;

    public function findOrCreateForSession(string $sessionId): Cart;

    public function addItem(Cart $cart, array $data): CartItem;

    public function updateItem(CartItem $item, array $data): CartItem;

    public function removeItem(CartItem $item): bool;

    public function clear(Cart $cart): void;

    public function countItems(Cart $cart): int;
}
