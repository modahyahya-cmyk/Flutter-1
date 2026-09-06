<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('idempotency_key', 100)->nullable()->after('order_number');
            // Per-customer idempotency: the same key can be reused by the SDK to
            // retry order creation without producing a duplicate order.
            $table->unique(['customer_id', 'idempotency_key'], 'orders_customer_idempotency_unique');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropUnique('orders_customer_idempotency_unique');
            $table->dropColumn('idempotency_key');
        });
    }
};
