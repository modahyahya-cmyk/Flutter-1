<?php

namespace Tests\Feature\Orders;

use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderCreationTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;
    private Vendor $vendor;

    protected function setUp(): void
    {
        parent::setUp();

        $this->customer = User::factory()->create(['password' => 'Password@123']);
        $this->vendor = Vendor::factory()->create(['status' => 'approved']);
    }

    private function login(string $email): array
    {
        $response = $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $email,
            'password' => 'Password@123',
        ]);
        $response->assertStatus(200);

        return $response->json('data');
    }

    private function authHeaders(): array
    {
        $tokens = $this->login($this->customer->email);

        return ['Authorization' => "Bearer {$tokens['access_token']}"];
    }

    private function makeProduct(array $attributes = []): Product
    {
        return Product::factory()->create(array_merge([
            'vendor_id' => $this->vendor->id,
            'status' => 'active',
            'price' => 25.00,
            'stock_quantity' => 50,
        ], $attributes));
    }

    private function makeVariant(Product $product, array $attributes = []): ProductVariant
    {
        return ProductVariant::create(array_merge([
            'product_id' => $product->id,
            'name' => 'Large',
            'price' => 30.00,
            'stock_quantity' => 10,
            'is_active' => true,
        ], $attributes));
    }

    private function orderPayload(Product $product, array $overrides = []): array
    {
        return array_merge([
            'vendor_id' => $this->vendor->id,
            'items' => [
                ['product_id' => $product->id, 'quantity' => 2],
            ],
            'payment_method' => 'cash_on_delivery',
        ], $overrides);
    }

    /**
     * The customer note key in the request (customer_notes) must reach the
     * orders table and be echoed back in the response.
     */
    public function test_order_creation_stores_customer_notes(): void
    {
        $product = $this->makeProduct();

        $this->postJson(
            '/api/v1/customer/orders',
            $this->orderPayload($product, ['customer_notes' => 'Please ring the doorbell twice.']),
            $this->authHeaders()
        )
            ->assertStatus(201)
            ->assertJsonPath('data.customer_notes', 'Please ring the doorbell twice.');

        $this->assertDatabaseHas('orders', [
            'customer_id' => $this->customer->id,
            'customer_notes' => 'Please ring the doorbell twice.',
        ]);
    }

    public function test_order_creation_rejects_inactive_product(): void
    {
        $product = $this->makeProduct(['status' => 'inactive']);

        $this->postJson('/api/v1/customer/orders', $this->orderPayload($product), $this->authHeaders())
            ->assertStatus(422);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_order_creation_rejects_draft_product(): void
    {
        $product = $this->makeProduct(['status' => 'draft']);

        $this->postJson('/api/v1/customer/orders', $this->orderPayload($product), $this->authHeaders())
            ->assertStatus(422);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_order_creation_rejects_inactive_variant(): void
    {
        $product = $this->makeProduct();
        $variant = $this->makeVariant($product, ['is_active' => false]);

        $this->postJson('/api/v1/customer/orders', $this->orderPayload($product, [
            'items' => [
                ['product_id' => $product->id, 'product_variant_id' => $variant->id, 'quantity' => 1],
            ],
        ]), $this->authHeaders())
            ->assertStatus(422);

        $this->assertDatabaseCount('orders', 0);
    }

    public function test_order_creation_rejects_variant_of_another_product(): void
    {
        $product = $this->makeProduct();
        $otherProduct = $this->makeProduct();
        $foreignVariant = $this->makeVariant($otherProduct);

        $this->postJson('/api/v1/customer/orders', $this->orderPayload($product, [
            'items' => [
                ['product_id' => $product->id, 'product_variant_id' => $foreignVariant->id, 'quantity' => 1],
            ],
        ]), $this->authHeaders())
            ->assertStatus(422);
    }

    public function test_order_creation_uses_variant_price_not_product_price(): void
    {
        $product = $this->makeProduct(['price' => 20.00]);
        $variant = $this->makeVariant($product, ['price' => 35.00]);

        $this->postJson('/api/v1/customer/orders', $this->orderPayload($product, [
            'items' => [
                ['product_id' => $product->id, 'product_variant_id' => $variant->id, 'quantity' => 2],
            ],
        ]), $this->authHeaders())
            ->assertStatus(201)
            ->assertJsonPath('data.items.0.unit_price', 35.00)
            ->assertJsonPath('data.items.0.total_amount', 70.00);
    }

    public function test_order_creation_rejects_unimplemented_wallet_payment(): void
    {
        $product = $this->makeProduct();

        $this->postJson('/api/v1/customer/orders', $this->orderPayload($product, [
            'payment_method' => 'wallet',
        ]), $this->authHeaders())
            ->assertStatus(422);

        $this->assertDatabaseCount('orders', 0);
    }
}
