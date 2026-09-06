<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Driver GPS position history.
 *
 * The drivers table only stores the driver's *current* position
 * (latitude/longitude/last_location_at). Offline-first drivers accumulate
 * points locally (with a captured_at timestamp they control) and flush them
 * here in batches. Retained for a configurable window; older rows can be
 * pruned by a scheduled job.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('location_history', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->foreignId('driver_id')->constrained('drivers')->cascadeOnDelete();
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->decimal('accuracy', 8, 2)->nullable();
            $table->float('speed_kmh')->nullable();
            $table->float('heading_deg')->nullable();
            $table->decimal('altitude_m', 8, 2)->nullable();
            $table->timestamp('captured_at')->index();
            $table->timestamps();

            $table->index(['driver_id', 'captured_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('location_history');
    }
};
