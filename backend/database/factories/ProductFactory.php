<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Product;
use App\Models\Vendor;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Product>
 */
class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        $name = $this->faker->words(3, true);

        return [
            'vendor_id' => Vendor::factory(),
            'category_id' => Category::factory(),
            'name' => ucfirst($name),
            'slug' => Str::slug($name).'-'.Str::random(6),
            'description' => $this->faker->paragraph(),
            'short_description' => $this->faker->sentence(),
            'price' => $this->faker->randomFloat(2, 5, 500),
            'compare_at_price' => $this->faker->optional(0.4)->randomFloat(2, 10, 600),
            'cost_price' => $this->faker->optional(0.6)->randomFloat(2, 1, 400),
            'is_taxable' => true,
            'tax_rate' => 5,
            'inventory_type' => 'single',
            'stock_quantity' => $this->faker->numberBetween(10, 200),
            'low_stock_threshold' => 5,
            'track_inventory' => true,
            'allow_backorder' => false,
            'status' => 'active',
            'is_featured' => $this->faker->boolean(20),
            'is_bestseller' => $this->faker->boolean(20),
            'total_sales' => $this->faker->numberBetween(0, 1000),
        ];
    }
}
