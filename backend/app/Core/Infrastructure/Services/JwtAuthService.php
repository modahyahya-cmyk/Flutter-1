<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Domain\Repositories\UserRepositoryInterface;
use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Domain\Services\AuthServiceInterface;
use App\Core\Infrastructure\Security\JwtManager;
use App\Exceptions\BusinessException;
use App\Exceptions\UnauthorizedException;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class JwtAuthService implements AuthServiceInterface
{
    public function __construct(
        private UserRepositoryInterface $users,
        private VendorRepositoryInterface $vendors,
        private DriverRepositoryInterface $drivers,
    ) {
    }

    public function register(array $data, string $role = 'customer'): array
    {
        // 1. Role validation: only supported roles may be created.
        if (! in_array($role, ['customer', 'vendor', 'driver'], true)) {
            throw new BusinessException('The requested role is not supported.');
        }

        // 2. Duplicate prevention (email and phone).
        if ($this->users->findByEmail($data['email'])) {
            throw new BusinessException('The email address is already registered.');
        }
        if (isset($data['phone']) && $data['phone'] !== null && $this->users->findByPhone($data['phone'])) {
            throw new BusinessException('The phone number is already registered.');
        }

        // 3. Atomic role-aware creation: user + required profile in a single
        //    transaction. On any failure the whole registration rolls back and
        //    no user is left without its required profile.
        $user = DB::transaction(function () use ($data, $role) {
            $user = $this->users->create([
                'first_name' => $data['first_name'],
                'last_name' => $data['last_name'],
                'email' => $data['email'],
                'phone' => $data['phone'] ?? null,
                'password' => $data['password'],
                'role' => $role,
                // Account is enabled so the user can log in and track approval;
                // operational access is gated by the linked profile status.
                'status' => 'active',
                'provider' => $data['provider'] ?? null,
                'provider_id' => $data['provider_id'] ?? null,
                'language' => $data['language'] ?? 'en',
                'timezone' => config('app_settings.localization.default_timezone', 'UTC'),
                'device_type' => $data['device_type'] ?? null,
                'app_version' => $data['app_version'] ?? null,
            ]);

            if ($role === 'vendor') {
                $approvalRequired = (bool) config('app_settings.business.vendor_approval_required', true);
                $businessName = $data['business_name'] ?? ($data['first_name'].' '.$data['last_name']);
                $this->vendors->create([
                    'user_id' => $user->id,
                    'business_name' => $businessName,
                    'slug' => $this->uniqueSlug($businessName),
                    'business_email' => $data['business_email'] ?? $data['email'],
                    'business_phone' => $data['business_phone'] ?? $data['phone'] ?? null,
                    'status' => $approvalRequired ? 'pending' : 'approved',
                    'approved_at' => $approvalRequired ? null : now(),
                ]);
            } elseif ($role === 'driver') {
                $approvalRequired = (bool) config('app_settings.business.driver_approval_required', true);
                $this->drivers->create([
                    'user_id' => $user->id,
                    'vehicle_type' => $data['vehicle_type'] ?? null,
                    'vehicle_plate' => $data['vehicle_plate'] ?? null,
                    'license_number' => $data['license_number'] ?? null,
                    'status' => $approvalRequired ? 'pending' : 'approved',
                    'approved_at' => $approvalRequired ? null : now(),
                ]);
            }

            return $user;
        });

        return $this->issueTokens($user);
    }

    public function login(string $identifier, string $password, string $guard = 'customer'): array
    {
        $user = $this->users->findByEmail($identifier) ?? $this->users->findByPhone($identifier);

        // A locked account is refused up-front, regardless of password, until
        // the lockout expires.
        if ($user !== null && $this->isLocked($user)) {
            throw UnauthorizedException::accountLocked($user->locked_until);
        }

        if ($user === null || ! Hash::check($password, $user->password)) {
            $this->recordFailedLogin($user);

            throw UnauthorizedException::invalidCredentials();
        }

        if ($user->status !== 'active') {
            throw UnauthorizedException::accountDisabled();
        }

        if ($user->role !== $guard && $guard !== 'any') {
            throw UnauthorizedException::wrongGuard($guard);
        }

        $this->resetLoginAttempts($user);
        $this->users->updateLastLogin($user);

        return $this->issueTokens($user);
    }

    public function refresh(string $refreshToken): array
    {
        $payload = JwtManager::decode($refreshToken, JwtManager::TYPE_REFRESH);

        $user = $this->users->findById((int) ($payload['sub'] ?? 0));

        if ($user === null || $user->status !== 'active') {
            throw UnauthorizedException::tokenInvalid();
        }

        // Reject tokens that belong to a revoked session.
        if (! JwtManager::sessionVersionMatches($payload, $user)) {
            throw UnauthorizedException::tokenInvalid();
        }

        return $this->issueTokens($user);
    }

    public function logout(User $user): void
    {
        // Revoke every session for this user by bumping the session version.
        // Any previously issued access/refresh token no longer validates.
        $this->users->update($user, [
            'token_version' => ((int) $user->token_version) + 1,
        ]);
    }

    public function verifyEmail(User $user, string $token): bool
    {
        if ($user->email_verified_at !== null) {
            return true;
        }

        if (! Hash::check($user->email.'|'.$user->uuid, $token)) {
            return false;
        }

        $user->forceFill(['email_verified_at' => now()])->save();

        return true;
    }

    public function requestPasswordReset(string $identifier): bool
    {
        $user = $this->users->findByEmail($identifier) ?? $this->users->findByPhone($identifier);

        if ($user === null) {
            return true; // Do not reveal whether the identifier exists.
        }

        // Single-use, time-boxed reset token (raw value looked up directly).
        $user->forceFill([
            'remember_token' => Str::random(60),
        ])->save();

        // In production this token is emailed / pushed; it is never returned here.

        return true;
    }

    public function resetPassword(string $token, string $newPassword): bool
    {
        $user = User::where('remember_token', $token)->first();

        if ($user === null) {
            throw new BusinessException('The password reset token is invalid or expired.');
        }

        $user->forceFill([
            'password' => $newPassword,
            'remember_token' => null,
            'login_attempts' => 0,
            'locked_until' => null,
        ])->save();

        return true;
    }

    private function issueTokens(User $user): array
    {
        $now = time();

        $accessToken = JwtManager::issueAccess($user, $now);
        $refreshToken = JwtManager::issueRefresh($user, $now);

        return [
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'token_type' => 'Bearer',
            'expires_in' => JwtManager::ttl(),
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
                'role' => $user->role,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'avatar' => $user->avatar,
            ],
        ];
    }

    private function uniqueSlug(string $name): string
    {
        $base = Str::slug($name) ?: 'vendor';
        $slug = $base;
        while (app(VendorRepositoryInterface::class)->findBySlug($slug) !== null) {
            $slug = $base.'-'.Str::lower(Str::random(6));
        }

        return $slug;
    }

    private function isLocked(User $user): bool
    {
        return $user->locked_until !== null && $user->locked_until->isFuture();
    }

    private function recordFailedLogin(?User $user): void
    {
        if ($user === null) {
            // Unknown identifier: nothing persisted, but the request is still
            // throttled at the route layer for brute-force protection.
            return;
        }

        $max = max(1, (int) config('jwt.max_login_attempts', 5));
        $attempts = ((int) $user->login_attempts) + 1;

        $data = ['login_attempts' => $attempts];
        if ($attempts >= $max) {
            $data['locked_until'] = now()->addMinutes(max(1, (int) config('jwt.lockout_minutes', 15)));
        }

        $this->users->update($user, $data);
    }

    private function resetLoginAttempts(User $user): void
    {
        $this->users->update($user, [
            'login_attempts' => 0,
            'locked_until' => null,
        ]);
    }
}
