<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('branches', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->foreignId('vendor_id')->constrained('vendors')->cascadeOnDelete();
            $table->string('name', 200);
            $table->string('slug', 220)->unique();
            $table->string('phone', 20)->nullable();
            $table->string('email', 191)->nullable();

            // Address
            $table->string('address_line_1');
            $table->string('address_line_2')->nullable();
            $table->string('city', 100);
            $table->string('state', 100)->nullable();
            $table->string('country', 100);
            $table->string('postal_code', 20)->nullable();

            // Geolocation
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);

            // Settings
            $table->boolean('is_primary')->default(false);
            $table->boolean('is_active')->default(true);
            $table->json('operating_hours')->nullable();
            $table->integer('preparation_time_minutes')->default(30);
            $table->decimal('delivery_radius_km', 6, 2)->default(10.00);

            $table->softDeletes();
            $table->timestamps();

            $table->index(['vendor_id', 'is_active']);
            $table->index(['latitude', 'longitude']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('branches');
    }
};
