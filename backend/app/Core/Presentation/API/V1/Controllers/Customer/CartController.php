<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\CartRepositoryInterface;
use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends BaseController
{
    public function __construct(
        private CartRepositoryInterface $carts,
        private ProductRepositoryInterface $products
    ) {
    }

    public function show(Request $request): JsonResponse
    {
        $cart = $this->resolveCart($request);

        return $this->success($this->cartPayload($cart));
    }

    public function add(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => ['required', 'exists:products,id'],
            'product_variant_id' => ['nullable', 'exists:product_variants,id'],
            'quantity' => ['required', 'integer', 'min:1', 'max:100'],
        ]);

        /** @var Product $product */
        $product = $this->products->findById((int) $validated['product_id']);
        abort_if($product === null, 404, 'Product not found.');

        $quantity = (int) $validated['quantity'];

        if ($product->track_inventory && $product->stock_quantity < $quantity) {
            return $this->success(null, 'Insufficient stock.', 409);
        }

        $cart = $this->resolveCart($request);

        $item = $this->carts->addItem($cart, [
            'product_id' => $product->id,
            'variant_id' => $validated['product_variant_id'] ?? null,
            'quantity' => $quantity,
            'unit_price' => $product->price,
            'unit_cost' => $product->cost_price ?? 0,
        ]);

        return $this->success($this->cartPayload($cart->fresh(['items.product', 'items.variant'])), 'Item added to cart.');
    }

    public function update(Request $request, int $cartItemId): JsonResponse
    {
        $validated = $request->validate(['quantity' => ['required', 'integer', 'min:1', 'max:100']]);

        $cart = $this->resolveCart($request);
        $item = $cart->items()->find($cartItemId);

        abort_if($item === null, 404, 'Cart item not found.');

        $this->carts->updateItem($item, [
            'quantity' => $validated['quantity'],
            'total_amount' => $item->unit_price * $validated['quantity'],
        ]);

        return $this->success($this->cartPayload($cart->fresh(['items.product', 'items.variant'])), 'Cart updated.');
    }

    public function remove(Request $request, int $cartItemId): JsonResponse
    {
        $cart = $this->resolveCart($request);
        $item = $cart->items()->find($cartItemId);

        abort_if($item === null, 404, 'Cart item not found.');

        $this->carts->removeItem($item);

        return $this->success($this->cartPayload($cart->fresh(['items.product'])), 'Item removed from cart.');
    }

    public function clear(Request $request): JsonResponse
    {
        $cart = $this->resolveCart($request);
        $this->carts->clear($cart);

        return $this->success($this->cartPayload($cart->fresh()), 'Cart cleared.');
    }

    private function resolveCart(Request $request): Cart
    {
        $userId = $request->attributes->get('user')?->id;

        return $this->carts->findOrCreateForUser((int) $userId);
    }

    private function cartPayload(Cart $cart): array
    {
        $items = $cart->items->map(fn ($item) => [
            'id' => $item->id,
            'product_id' => $item->product_id,
            'variant_id' => $item->variant_id,
            'quantity' => $item->quantity,
            'unit_price' => (float) $item->unit_price,
            'total_amount' => (float) $item->total_amount,
            'product' => $item->product ? [
                'name' => $item->product->name,
                'main_image' => $item->product->thumbnail,
                'slug' => $item->product->slug,
            ] : null,
        ])->values();

        return [
            'id' => $cart->id,
            'subtotal' => (float) $cart->subtotal,
            'tax_amount' => (float) $cart->tax_amount,
            'total_amount' => (float) $cart->total_amount,
            'items' => $items,
        ];
    }
}
