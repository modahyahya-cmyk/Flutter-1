<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->string('order_number', 50)->unique()->index();

            // Relationships
            $table->foreignId('customer_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('vendor_id')->constrained('vendors')->restrictOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained('branches')->nullOnDelete();
            $table->foreignId('driver_id')->nullable()->constrained('drivers')->nullOnDelete();

            // Order type
            $table->enum('order_type', ['delivery', 'pickup', 'dine_in'])->default('delivery')->index();

            // Status
            $table->enum('status', [
                'pending', 'confirmed', 'preparing', 'ready_for_pickup',
                'out_for_delivery', 'delivered', 'cancelled', 'refunded',
            ])->default('pending')->index();

            $table->enum('payment_status', [
                'pending', 'processing', 'completed', 'failed', 'refunded',
            ])->default('pending')->index();

            // Amounts
            $table->decimal('subtotal', 10, 2);
            $table->decimal('tax_amount', 10, 2)->default(0.00);
            $table->decimal('delivery_fee', 10, 2)->default(0.00);
            $table->decimal('discount_amount', 10, 2)->default(0.00);
            $table->decimal('tip_amount', 10, 2)->default(0.00);
            $table->decimal('total_amount', 10, 2);
            $table->decimal('commission_amount', 10, 2)->default(0.00);
            $table->decimal('vendor_earnings', 10, 2)->default(0.00);

            // Delivery details
            $table->text('delivery_address')->nullable();
            $table->decimal('delivery_latitude', 10, 8)->nullable();
            $table->decimal('delivery_longitude', 11, 8)->nullable();
            $table->string('delivery_phone', 20)->nullable();
            $table->text('delivery_notes')->nullable();
            $table->decimal('delivery_distance_km', 6, 2)->nullable();

            // Timestamps
            $table->timestamp('confirmed_at')->nullable();
            $table->timestamp('preparing_at')->nullable();
            $table->timestamp('ready_at')->nullable();
            $table->timestamp('picked_up_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamp('scheduled_for')->nullable();

            // Notes
            $table->text('customer_notes')->nullable();
            $table->text('vendor_notes')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->string('payment_method', 50)->nullable();
            $table->string('payment_transaction_id')->nullable();

            // Ratings
            $table->unsignedTinyInteger('customer_rating')->nullable();
            $table->text('customer_review')->nullable();
            $table->timestamp('reviewed_at')->nullable();

            $table->softDeletes();
            $table->timestamps();

            $table->index(['customer_id', 'status']);
            $table->index(['vendor_id', 'status']);
            $table->index(['driver_id', 'status']);
            $table->index(['status', 'created_at']);
            $table->index(['payment_status', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
