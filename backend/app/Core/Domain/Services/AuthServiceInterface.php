<?php

namespace App\Core\Domain\Services;

use App\Models\User;

interface AuthServiceInterface
{
    public function register(array $data, string $role = 'customer'): array;

    public function login(string $identifier, string $password, string $guard = 'customer'): array;

    public function refresh(string $refreshToken): array;

    public function logout(User $user): void;

    public function verifyEmail(User $user, string $token): bool;

    public function requestPasswordReset(string $identifier): bool;

    public function resetPassword(string $token, string $newPassword): bool;
}
