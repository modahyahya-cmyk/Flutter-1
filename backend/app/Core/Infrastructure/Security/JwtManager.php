<?php

declare(strict_types=1);

namespace App\Core\Infrastructure\Security;

use App\Exceptions\UnauthorizedException;
use App\Models\User;
use Firebase\JWT\ExpiredException;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

/**
 * Single source of truth for JWT signing, decoding and session versions.
 *
 * Both the auth service (issuing tokens) and the API middlewares (validating
 * them) go through this class so that secret handling, algorithm selection,
 * token-type and revocation checks are always consistent.
 *
 * Fail-closed: if JWT_SECRET is not configured, the whole auth layer refuses
 * to operate rather than silently falling back to an insecure default.
 */
final class JwtManager
{
    public const TYPE_ACCESS = 'access';
    public const TYPE_REFRESH = 'refresh';

    private function __construct()
    {
    }

    public static function secret(): string
    {
        $secret = config('jwt.secret');

        if (! is_string($secret) || $secret === '') {
            throw new \RuntimeException(
                'JWT_SECRET is not configured. Set a strong random value (e.g. "php artisan key:generate" output) before running in production.'
            );
        }

        return $secret;
    }

    public static function algo(): string
    {
        return (string) config('jwt.algo', 'HS256');
    }

    public static function issuer(): string
    {
        return (string) (config('app.url') ?: 'vendorhub');
    }

    public static function ttl(): int
    {
        return max(1, (int) config('jwt.ttl', 1440)) * 60;
    }

    public static function refreshTtl(): int
    {
        return max(1, (int) config('jwt.refresh_ttl', 20160)) * 60;
    }

    public static function issueAccess(User $user, int $now): string
    {
        return JWT::encode(self::claims($user, self::TYPE_ACCESS, $now, self::ttl()), self::secret(), self::algo());
    }

    public static function issueRefresh(User $user, int $now): string
    {
        return JWT::encode(self::claims($user, self::TYPE_REFRESH, $now, self::refreshTtl()), self::secret(), self::algo());
    }

    /**
     * Decodes a token, enforces the signature/expiry and the expected token type.
     * A refresh token can never be validated as an access token (and vice versa).
     */
    public static function decode(string $token, string $expectedType): array
    {
        try {
            $payload = (array) JWT::decode($token, new Key(self::secret(), self::algo()));
        } catch (ExpiredException $e) {
            throw UnauthorizedException::tokenExpired();
        } catch (\Throwable $e) {
            throw UnauthorizedException::tokenInvalid();
        }

        if (($payload['type'] ?? null) !== $expectedType) {
            throw UnauthorizedException::tokenInvalid();
        }

        return $payload;
    }

    /**
     * True when the token's session version (revocation claim) matches the
     * user's current version. After a logout the version is bumped, so any
     * previously issued token becomes invalid.
     */
    public static function sessionVersionMatches(array $payload, User $user): bool
    {
        $claim = (string) config('jwt.version_claim', 'ver');

        return (int) ($payload[$claim] ?? 0) === (int) $user->token_version;
    }

    private static function claims(User $user, string $type, int $now, int $expiresIn): array
    {
        $versionClaim = (string) config('jwt.version_claim', 'ver');

        return [
            'iss' => self::issuer(),
            'sub' => (int) $user->id,
            'role' => $user->role,
            'type' => $type,
            $versionClaim => (int) $user->token_version,
            'iat' => $now,
            'exp' => $now + $expiresIn,
        ];
    }
}
