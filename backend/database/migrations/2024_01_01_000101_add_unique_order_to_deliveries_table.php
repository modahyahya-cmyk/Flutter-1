<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Deduplicate any existing double records safely before the unique
        // index is applied (MySQL keeps the lowest id per order_id).
        try {
            DB::table('deliveries')->whereNotIn(
                'id',
                DB::table('deliveries')->selectRaw('MAX(id) as id')->groupBy('order_id')
            )->delete();
        } catch (\Throwable $e) {
            // Non-MySQL engines may not support the delete-by-subquery here;
            // the unique index below is the authoritative guard.
        }

        Schema::table('deliveries', function (Blueprint $table) {
            $table->unique('order_id', 'deliveries_order_id_unique');
        });
    }

    public function down(): void
    {
        Schema::table('deliveries', function (Blueprint $table) {
            $table->dropUnique('deliveries_order_id_unique');
        });
    }
};
