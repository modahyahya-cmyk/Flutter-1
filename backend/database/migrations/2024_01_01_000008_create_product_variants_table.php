<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_variants', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->foreignId('product_id')->constrained('products')->cascadeOnDelete();
            $table->string('name', 200); // e.g. "Large / Red"
            $table->string('sku', 100)->nullable()->unique();
            $table->string('barcode', 100)->nullable();

            // Pricing
            $table->decimal('price', 10, 2);
            $table->decimal('compare_at_price', 10, 2)->nullable();
            $table->decimal('cost_price', 10, 2)->nullable();

            // Inventory
            $table->integer('stock_quantity')->default(0);
            $table->boolean('track_inventory')->default(true);

            // Attributes
            $table->json('options'); // {"size":"Large","color":"Red"}

            // Media
            $table->string('image')->nullable();

            // Status
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);

            $table->timestamps();

            $table->index(['product_id', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_variants');
    }
};
