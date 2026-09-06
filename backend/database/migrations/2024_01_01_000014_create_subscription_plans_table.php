<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->string('name', 200);
            $table->string('code', 100)->unique()->index();
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->enum('billing_cycle', ['daily', 'weekly', 'monthly', 'yearly'])->default('monthly');
            $table->unsignedInteger('duration_days')->default(30);
            $table->decimal('discounted_price', 10, 2)->nullable();
            $table->boolean('featured')->default(false);
            $table->json('features')->nullable();
            $table->decimal('commission_rate', 5, 2)->nullable();
            $table->boolean('is_active')->default(true)->index();
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('meta_title')->nullable();
            $table->text('meta_description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_plans');
    }
};
