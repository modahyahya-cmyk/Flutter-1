<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_register(): void
    {
        $response = $this->postJson('/api/v1/customer/auth/register', [
            'first_name' => 'John',
            'last_name' => 'Doe',
            'email' => 'john@example.com',
            'phone' => '+15551234567',
            'password' => 'Password@123',
        ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true])
            ->assertJsonStructure([
                'data' => ['access_token', 'refresh_token', 'token_type', 'user'],
            ]);

        $this->assertDatabaseHas('users', ['email' => 'john@example.com']);
    }

    public function test_customer_can_login(): void
    {
        User::factory()->create(['email' => 'login@example.com', 'password' => 'Password@123']);

        $response = $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => 'login@example.com',
            'password' => 'Password@123',
        ]);

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure(['data' => ['access_token', 'user']]);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create(['email' => 'login2@example.com', 'password' => 'Password@123']);

        $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => 'login2@example.com',
            'password' => 'WrongPassword',
        ])->assertStatus(401);
    }

    public function test_customer_can_access_profile_with_token(): void
    {
        $user = User::factory()->create();
        $login = $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $user->email,
            'password' => 'Password@123',
        ])->json('data');

        $this->withHeaders(['Authorization' => "Bearer {$login['access_token']}"])
            ->getJson('/api/v1/customer/profile')
            ->assertStatus(200)
            ->assertJson(['success' => true]);
    }
}
