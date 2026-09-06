<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vendors', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('business_name', 200)->index();
            $table->string('slug', 220)->unique();
            $table->text('description')->nullable();
            $table->string('business_email', 191)->nullable();
            $table->string('business_phone', 20)->nullable();
            $table->string('business_registration_number', 100)->nullable();
            $table->string('tax_id', 100)->nullable();
            $table->string('logo')->nullable();
            $table->string('banner')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'suspended'])->default('pending')->index();
            $table->text('rejection_reason')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();

            // Bank details for payouts
            $table->string('bank_name', 100)->nullable();
            $table->string('account_holder_name', 200)->nullable();
            $table->string('account_number', 100)->nullable();
            $table->string('routing_number', 100)->nullable();
            $table->string('swift_code', 50)->nullable();

            // Business metrics
            $table->decimal('commission_rate', 5, 2)->default(15.00);
            $table->decimal('rating', 3, 2)->default(0.00);
            $table->unsignedInteger('total_reviews')->default(0);
            $table->unsignedInteger('total_orders')->default(0);
            $table->decimal('total_earnings', 12, 2)->default(0.00);
            $table->decimal('pending_balance', 12, 2)->default(0.00);
            $table->decimal('available_balance', 12, 2)->default(0.00);

            // Operating hours (JSON)
            $table->json('operating_hours')->nullable();

            // Features
            $table->boolean('is_featured')->default(false);
            $table->boolean('is_verified')->default(false);
            $table->boolean('accepts_orders')->default(true);
            $table->boolean('auto_accept_orders')->default(false);
            $table->integer('preparation_time_minutes')->default(30);
            $table->decimal('min_order_amount', 10, 2)->default(0.00);
            $table->decimal('delivery_radius_km', 6, 2)->default(10.00);

            // SEO
            $table->string('meta_title')->nullable();
            $table->text('meta_description')->nullable();
            $table->string('meta_keywords')->nullable();

            $table->softDeletes();
            $table->timestamps();

            $table->index(['status', 'is_featured']);
            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendors');
    }
};
