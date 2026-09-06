<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->foreignId('vendor_id')->constrained('vendors')->cascadeOnDelete();
            $table->foreignId('category_id')->constrained('categories')->restrictOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->string('name', 200)->index();
            $table->string('slug', 220)->unique();
            $table->text('description')->nullable();
            $table->text('short_description')->nullable();
            $table->string('sku', 100)->nullable()->unique();
            $table->string('barcode', 100)->nullable();

            // Pricing
            $table->decimal('price', 10, 2);
            $table->decimal('compare_at_price', 10, 2)->nullable();
            $table->decimal('cost_price', 10, 2)->nullable();
            $table->boolean('is_taxable')->default(true);
            $table->decimal('tax_rate', 5, 2)->default(0.00);

            // Inventory
            $table->enum('inventory_type', ['single', 'variant'])->default('single');
            $table->integer('stock_quantity')->default(0);
            $table->integer('low_stock_threshold')->default(10);
            $table->boolean('track_inventory')->default(true);
            $table->boolean('allow_backorder')->default(false);

            // Media
            $table->string('thumbnail')->nullable();
            $table->json('images')->nullable();
            $table->unsignedBigInteger('video_id')->nullable()->index(); // plain FK to videos (created prior)

            // Attributes
            $table->string('unit', 50)->nullable();
            $table->decimal('weight', 8, 2)->nullable();
            $table->json('dimensions')->nullable();

            // Status & visibility
            $table->enum('status', ['draft', 'active', 'inactive', 'out_of_stock'])->default('draft')->index();
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_new_arrival')->default(false);
            $table->boolean('is_bestseller')->default(false);

            // Metrics
            $table->decimal('rating', 3, 2)->default(0.00);
            $table->unsignedInteger('total_reviews')->default(0);
            $table->unsignedInteger('total_sales')->default(0);
            $table->unsignedInteger('view_count')->default(0);

            // SEO
            $table->string('meta_title')->nullable();
            $table->text('meta_description')->nullable();
            $table->string('meta_keywords')->nullable();

            $table->timestamp('available_from')->nullable();
            $table->timestamp('available_until')->nullable();

            $table->softDeletes();
            $table->timestamps();

            $table->index(['vendor_id', 'status']);
            $table->index(['category_id', 'status']);
            $table->index(['is_featured', 'status']);
            $table->index(['status', 'created_at']);

            // MySQL supports a native FULLTEXT index; SQLite/other drivers do not.
            // Only add it on MySQL so the migration is portable (keeps the
            // in-memory SQLite test DB migratable). `name` is already indexed
            // above, so plain drivers need no extra index here.
            if (Schema::getConnection()->getDriverName() === 'mysql') {
                $table->fullText(['name', 'description', 'short_description']);
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
