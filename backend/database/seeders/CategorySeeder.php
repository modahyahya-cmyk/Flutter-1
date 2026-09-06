<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Electronics', 'icon' => 'device_mobile'],
            ['name' => 'Fashion', 'icon' => 'checkroom'],
            ['name' => 'Groceries', 'icon' => 'local_grocery_store'],
            ['name' => 'Home & Living', 'icon' => 'home'],
            ['name' => 'Beauty & Health', 'icon' => 'spa'],
            ['name' => 'Sports & Outdoors', 'icon' => 'sports_soccer'],
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate([
                'slug' => Str::slug($category['name']),
            ], [
                'name' => $category['name'],
                'icon' => $category['icon'],
                'is_active' => true,
                'sort_order' => Category::max('sort_order') + 1,
            ]);
        }
    }
}
