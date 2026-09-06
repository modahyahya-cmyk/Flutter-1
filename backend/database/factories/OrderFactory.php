<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Order>
 */
class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        $subtotal = $this->faker->randomFloat(2, 20, 300);
        $delivery = 5.00;
        $tax = round($subtotal * 0.05, 2);

        return [
            'order_number' => 'ORD-'.strtoupper(Str::orderedUuid()->toString()),
            'customer_id' => User::factory(),
            'vendor_id' => Vendor::factory(),
            'order_type' => 'delivery',
            'subtotal' => $subtotal,
            'tax_amount' => $tax,
            'delivery_fee' => $delivery,
            'total_amount' => round($subtotal + $delivery + $tax, 2),
            'commission_amount' => round($subtotal * 0.15, 2),
            'vendor_earnings' => round($subtotal * 0.85, 2),
            'status' => 'pending',
            'payment_status' => 'pending',
            'payment_method' => 'stripe',
        ];
    }

    public function completed(): static
    {
        return $this->state(fn () => [
            'status' => 'delivered',
            'payment_status' => 'completed',
            'delivered_at' => now(),
            'confirmed_at' => now()->subMinutes(5),
        ]);
    }
}
