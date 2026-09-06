<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use App\Models\Vendor;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApprovalTest extends TestCase
{
    use RefreshDatabase;

    public function test_pending_vendor_is_blocked_from_operational_routes(): void
    {
        $user = User::factory()->create(['role' => 'vendor', 'password' => 'Password@123']);
        Vendor::query()->create([
            'user_id' => $user->id,
            'business_name' => 'Pending Shop',
            'slug' => 'pending-shop',
            'status' => 'pending',
        ]);

        $tokens = $this->login($user->email);

        // Operational route must be blocked for a pending (unapproved) vendor.
        $this->withHeaders(['Authorization' => "Bearer {$tokens['access_token']}"])
            ->getJson('/api/v1/vendor/products')
            ->assertStatus(403);
    }

    public function test_approved_vendor_can_access_operational_routes(): void
    {
        $user = User::factory()->create(['role' => 'vendor', 'password' => 'Password@123']);
        Vendor::query()->create([
            'user_id' => $user->id,
            'business_name' => 'Approved Shop',
            'slug' => 'approved-shop',
            'status' => 'approved',
        ]);

        $tokens = $this->login($user->email);

        $this->withHeaders(['Authorization' => "Bearer {$tokens['access_token']}"])
            ->getJson('/api/v1/vendor/products')
            ->assertStatus(200);
    }

    public function test_suspended_vendor_cannot_operate(): void
    {
        $user = User::factory()->create(['role' => 'vendor', 'password' => 'Password@123']);
        Vendor::query()->create([
            'user_id' => $user->id,
            'business_name' => 'Suspended Shop',
            'slug' => 'suspended-shop',
            'status' => 'suspended',
        ]);

        $tokens = $this->login($user->email);

        $this->withHeaders(['Authorization' => "Bearer {$tokens['access_token']}"])
            ->getJson('/api/v1/vendor/products')
            ->assertStatus(403);
    }

    private function login(string $email): array
    {
        $response = $this->postJson('/api/v1/vendor/auth/login', [
            'identifier' => $email,
            'password' => 'Password@123',
        ])->assertStatus(200);

        return $response->json('data');
    }
}
