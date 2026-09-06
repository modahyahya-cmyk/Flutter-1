<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthSecurityTest extends TestCase
{
    use RefreshDatabase;

    /**
     * A refresh token must never be accepted as an access token.
     */
    public function test_refresh_token_cannot_be_used_as_access_token(): void
    {
        $user = User::factory()->create(['password' => 'Password@123']);
        $tokens = $this->login($user->email);

        $this->withHeaders(['Authorization' => "Bearer {$tokens['refresh_token']}"])
            ->getJson('/api/v1/customer/profile')
            ->assertStatus(401);
    }

    /**
     * Logout must revoke the current session so the old access token is rejected.
     */
    public function test_logout_revokes_access_token(): void
    {
        $user = User::factory()->create(['password' => 'Password@123']);
        $tokens = $this->login($user->email);

        // Logout, which bumps the session version.
        $this->withHeaders(['Authorization' => "Bearer {$tokens['access_token']}"])
            ->postJson('/api/v1/customer/auth/logout')
            ->assertStatus(200);

        // The previously issued access token must now be refused.
        $this->withHeaders(['Authorization' => "Bearer {$tokens['access_token']}"])
            ->getJson('/api/v1/customer/profile')
            ->assertStatus(401);
    }

    /**
     * After too many failed attempts the account is locked and even a correct
     * password is rejected until the lockout expires.
     */
    public function test_account_is_locked_after_repeated_failed_logins(): void
    {
        $user = User::factory()->create(['password' => 'Password@123']);

        // MAX_LOGIN_ATTEMPTS is 3 in test env.
        for ($i = 0; $i < 3; $i++) {
            $this->postJson('/api/v1/customer/auth/login', [
                'identifier' => $user->email,
                'password' => 'WrongPassword',
            ])->assertStatus(401);
        }

        // On reaching the threshold the account becomes locked (429).
        $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $user->email,
            'password' => 'WrongPassword',
        ])->assertStatus(429);

        // Even the correct password is refused while locked.
        $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $user->email,
            'password' => 'Password@123',
        ])->assertStatus(429);

        $this->assertNotNull($user->fresh()->locked_until);
    }

    /**
     * A successful login after a non-locking failure resets the attempt counter.
     */
    public function test_successful_login_resets_attempt_counter(): void
    {
        $user = User::factory()->create(['password' => 'Password@123']);

        $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $user->email,
            'password' => 'WrongPassword',
        ])->assertStatus(401);

        $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $user->email,
            'password' => 'Password@123',
        ])->assertStatus(200);

        $this->assertSame(0, $user->fresh()->login_attempts);
        $this->assertNull($user->fresh()->locked_until);
    }

    /**
     * A valid refresh token yields a new access token; an access token must
     * NOT be accepted for refresh.
     */
    public function test_refresh_round_trip_and_type_rejection(): void
    {
        $user = User::factory()->create(['password' => 'Password@123']);
        $tokens = $this->login($user->email);

        $fresh = $this->postJson('/api/v1/customer/auth/refresh', [
            'refresh_token' => $tokens['refresh_token'],
        ])->assertStatus(200)->json('data');

        $this->assertArrayHasKey('access_token', $fresh);
        $this->assertArrayHasKey('refresh_token', $fresh);

        // Using an ACCESS token as a refresh token is rejected.
        $this->postJson('/api/v1/customer/auth/refresh', [
            'refresh_token' => $tokens['access_token'],
        ])->assertStatus(401);
    }

    /**
     * A user of the wrong role cannot reach a role-scoped portal.
     */
    public function test_wrong_role_cannot_access_other_portal(): void
    {
        $user = User::factory()->create(['password' => 'Password@123', 'role' => 'customer']);
        $tokens = $this->login($user->email);

        $this->withHeaders(['Authorization' => "Bearer {$tokens['access_token']}"])
            ->getJson('/api/v1/vendor/profile')
            ->assertStatus(403);
    }

    private function login(string $email): array
    {
        $response = $this->postJson('/api/v1/customer/auth/login', [
            'identifier' => $email,
            'password' => 'Password@123',
        ])->assertStatus(200);

        return $response->json('data');
    }
}
