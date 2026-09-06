<?php

namespace Tests\Feature\Auth;

use App\Models\Driver;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_vendor_registration_creates_user_and_pending_vendor_profile(): void
    {
        $response = $this->postJson('/api/v1/vendor/auth/register', [
            'first_name' => 'Aya',
            'last_name' => 'Bakery',
            'email' => 'vendor@example.com',
            'phone' => '+15550000001',
            'password' => 'Password@123',
            'business_name' => 'Aya Bakery',
        ]);

        $response->assertStatus(201)->assertJson(['success' => true]);

        $this->assertDatabaseHas('users', ['email' => 'vendor@example.com', 'role' => 'vendor']);
        // The profile must exist and default to pending (approval required).
        $vendor = Vendor::whereHas('user', fn ($q) => $q->where('email', 'vendor@example.com'))->first();
        $this->assertNotNull($vendor);
        $this->assertSame('pending', $vendor->status);
    }

    public function test_driver_registration_creates_user_and_pending_driver_profile(): void
    {
        $this->postJson('/api/v1/driver/auth/register', [
            'first_name' => 'Omar',
            'last_name' => 'Driver',
            'email' => 'driver@example.com',
            'phone' => '+15550000002',
            'password' => 'Password@123',
            'vehicle_type' => 'motorcycle',
            'license_number' => 'LIC-12345',
        ])->assertStatus(201);

        $this->assertDatabaseHas('users', ['email' => 'driver@example.com', 'role' => 'driver']);
        $driver = Driver::whereHas('user', fn ($q) => $q->where('email', 'driver@example.com'))->first();
        $this->assertNotNull($driver);
        $this->assertSame('pending', $driver->status);
    }

    public function test_customer_registration_creates_no_role_profile(): void
    {
        $this->postJson('/api/v1/customer/auth/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'email' => 'cust@example.com',
            'phone' => '+15550000003',
            'password' => 'Password@123',
        ])->assertStatus(201);

        $this->assertDatabaseMissing('vendors', ['user_id' => 1]);
        $this->assertDatabaseMissing('drivers', ['user_id' => 1]);
    }

    public function test_duplicate_email_is_rejected_without_partial_profile(): void
    {
        $payload = [
            'first_name' => 'Dup',
            'last_name' => 'Vendor',
            'email' => 'dup@example.com',
            'phone' => '+15550000004',
            'password' => 'Password@123',
            'business_name' => 'Dup Shop',
        ];

        $this->postJson('/api/v1/vendor/auth/register', $payload)->assertStatus(201);

        // Second attempt with the same email must fail and create no new rows.
        $this->postJson('/api/v1/vendor/auth/register', $payload)->assertStatus(422);

        $this->assertDatabaseCount('users', 1);
        $this->assertDatabaseCount('vendors', 1);
    }

    public function test_unsupported_role_is_rejected(): void
    {
        $this->postJson('/api/v1/customer/auth/register', [
            'first_name' => 'Bad',
            'last_name' => 'Role',
            'email' => 'bad@example.com',
            'phone' => '+15550000005',
            'password' => 'Password@123',
            'role' => 'superadmin',
        ])->assertStatus(422);
    }
}
