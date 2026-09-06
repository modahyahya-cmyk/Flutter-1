<?php

namespace App\Exceptions;

use Exception;

class UnauthorizedException extends Exception
{
    public static function invalidCredentials(): self
    {
        return new self('Invalid email/phone or password.', 401);
    }

    public static function accountDisabled(): self
    {
        return new self('This account has been disabled by the administrator.', 403);
    }

    public static function wrongGuard(string $guard): self
    {
        return new self("This account does not have access to the {$guard} portal.", 403);
    }

    public static function tokenRequired(): self
    {
        return new self('Authentication token is required.', 401);
    }

    public static function tokenInvalid(): self
    {
        return new self('Authentication token is invalid.', 401);
    }

    public static function tokenExpired(): self
    {
        return new self('Your session has expired. Please sign in again.', 401);
    }

    public static function accountLocked(\DateTimeInterface $until): self
    {
        return new self(
            'Too many failed login attempts. Try again after '.$until->format('Y-m-d H:i').'.',
            429
        );
    }

    public static function forbidden(): self
    {
        return new self('You do not have permission to perform this action.', 403);
    }

    public function toArray(): array
    {
        return [
            'success' => false,
            'message' => $this->getMessage(),
            'error_code' => 'UNAUTHORIZED',
        ];
    }
}
