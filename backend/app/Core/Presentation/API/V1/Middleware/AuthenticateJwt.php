<?php

namespace App\Core\Presentation\API\V1\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Exceptions\UnauthorizedException;
use App\Core\Infrastructure\Security\JwtManager;

abstract class AuthenticateJwt
{
    protected string $requiredRole = 'any';

    abstract public function handle(Request $request, Closure $next);

    protected function authenticate(Request $request): \App\Models\User
    {
        $token = $this->extractToken($request);

        // Decodes with signature + expiry checks AND enforces that this is an
        // ACCESS token (a refresh token is never accepted as an access token).
        $payload = JwtManager::decode($token, JwtManager::TYPE_ACCESS);

        $user = $this->resolveUser($payload);

        if (! JwtManager::sessionVersionMatches($payload, $user)) {
            // The session was revoked (logout): the token is no longer valid.
            throw UnauthorizedException::tokenInvalid();
        }

        if ($this->requiredRole !== 'any' && $user->role !== $this->requiredRole) {
            throw UnauthorizedException::wrongGuard($this->requiredRole);
        }

        if ($user->status !== 'active') {
            throw UnauthorizedException::accountDisabled();
        }

        return $user;
    }

    private function extractToken(Request $request): string
    {
        $header = $request->header('Authorization');

        if ($header === null || ! str_starts_with($header, 'Bearer ')) {
            throw UnauthorizedException::tokenRequired();
        }

        return substr($header, 7);
    }

    private function resolveUser(array $payload): \App\Models\User
    {
        $user = \App\Models\User::find((int) ($payload['sub'] ?? 0));

        if ($user === null) {
            throw UnauthorizedException::tokenInvalid();
        }

        return $user;
    }
}
