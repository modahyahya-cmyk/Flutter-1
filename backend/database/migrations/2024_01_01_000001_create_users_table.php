<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique()->index();
            $table->string('first_name', 100);
            $table->string('last_name', 100);
            $table->string('email', 191)->unique();
            $table->string('phone', 20)->nullable()->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('password');
            $table->enum('role', ['customer', 'vendor', 'driver', 'admin'])->default('customer')->index();
            $table->enum('status', ['active', 'inactive', 'suspended', 'banned'])->default('active')->index();
            $table->string('avatar')->nullable();
            $table->string('provider')->nullable(); // google, facebook, apple
            $table->string('provider_id')->nullable();
            $table->string('fcm_token')->nullable();
            $table->string('device_type')->nullable(); // ios, android, web
            $table->string('app_version')->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->ipAddress('last_login_ip')->nullable();
            $table->unsignedInteger('login_attempts')->default(0);
            $table->timestamp('locked_until')->nullable();
            $table->string('language', 5)->default('en');
            $table->string('timezone', 50)->default('UTC');
            $table->boolean('email_notifications')->default(true);
            $table->boolean('push_notifications')->default(true);
            $table->boolean('sms_notifications')->default(false);
            $table->rememberToken();
            $table->softDeletes();
            $table->timestamps();

            $table->index(['email', 'status']);
            $table->index(['role', 'status']);
            $table->index(['provider', 'provider_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
