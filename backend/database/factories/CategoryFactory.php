<?php

namespace Database\Factories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Category>
 */
class CategoryFactory extends Factory
{
    protected $model = Category::class;

    public function definition(): array
    {
        $name = $this->faker->word;

        return [
            'name' => ucfirst($name),
            'slug' => Str::slug($name).'-'.Str::random(5),
            'description' => $this->faker->sentence(),
            'sort_order' => 0,
            'is_active' => true,
            'is_featured' => false,
        ];
    }
}
