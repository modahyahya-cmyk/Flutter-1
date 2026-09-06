<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Vendor>
 */
class VendorFactory extends Factory
{
    protected $model = Vendor::class;

    public function definition(): array
    {
        $name = $this->faker->unique()->company();

        return [
            'user_id' => User::factory()->create(['role' => 'vendor']),
            'business_name' => $name,
            'slug' => Str::slug($name).'-'.Str::random(6),
            'description' => $this->faker->paragraph(),
            'business_email' => $this->faker->unique()->safeEmail(),
            'business_phone' => $this->faker->phoneNumber(),
            'status' => 'approved',
            'commission_rate' => 15,
            'rating' => $this->faker->randomFloat(2, 3, 5),
            'total_reviews' => $this->faker->numberBetween(0, 200),
            'total_orders' => $this->faker->numberBetween(0, 500),
            'total_earnings' => $this->faker->randomFloat(2, 0, 10000),
            'pending_balance' => 0.00,
            'available_balance' => 0.00,
            'operating_hours' => [
                ['day' => 'monday', 'open' => '09:00', 'close' => '22:00'],
                ['day' => 'tuesday', 'open' => '09:00', 'close' => '22:00'],
            ],
            'is_featured' => false,
            'is_verified' => true,
            'accepts_orders' => true,
            'auto_accept_orders' => true,
            'preparation_time_minutes' => $this->faker->numberBetween(10, 45),
            'min_order_amount' => $this->faker->randomFloat(2, 5, 50),
            'delivery_radius_km' => $this->faker->randomFloat(1, 3, 20),
        ];
    }
}
