<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('drivers', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('vehicle_type', 50)->default('motorcycle');
            $table->string('vehicle_plate', 50)->nullable();
            $table->string('vehicle_color', 50)->nullable();
            $table->string('license_number')->nullable();
            $table->string('license_image')->nullable();
            $table->string('id_card')->nullable();
            $table->string('national_id', 50)->nullable();
            $table->date('license_expiry')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'suspended', 'offline'])->default('pending')->index();
            $table->text('rejection_reason')->nullable();
            $table->boolean('is_online')->default(false)->index();
            $table->boolean('is_available')->default(false);
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->timestamp('last_location_at')->nullable();
            $table->decimal('rating', 3, 2)->default(0.00);
            $table->unsignedInteger('total_reviews')->default(0);
            $table->decimal('total_earnings', 12, 2)->default(0.00);
            $table->decimal('pending_balance', 12, 2)->default(0.00);
            $table->decimal('available_balance', 12, 2)->default(0.00);
            $table->unsignedInteger('total_deliveries')->default(0);
            $table->unsignedInteger('completed_deliveries')->default(0);
            $table->boolean('is_verified')->default(false);
            $table->timestamp('approved_at')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->softDeletes();
            $table->timestamps();

            $table->index(['status', 'is_online']);
            $table->index(['is_available', 'status']);
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('drivers');
    }
};
