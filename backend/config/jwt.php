<?php

declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| JWT Authentication
|--------------------------------------------------------------------------
| Central configuration for the token layer. The signing secret MUST come
| from the JWT_SECRET environment variable. There is deliberately NO fallback
| secret: signing JWTs with a known/default secret is a critical security
| flaw. When JWT_SECRET is missing the auth layer fails closed.
*/

return [
    // Signing secret. Required. Never ship a default value.
    'secret' => env('JWT_SECRET'),

    'algo' => env('JWT_ALGO', 'HS256'),

    // Access-token lifetime (minutes).
    'ttl' => (int) env('JWT_TTL', 1440),

    // Refresh-token lifetime (minutes).
    'refresh_ttl' => (int) env('JWT_REFRESH_TTL', 20160),

    // Claim used to carry the per-user session revocation version.
    'version_claim' => 'ver',

    // Failed-login lockout policy.
    'max_login_attempts' => (int) env('MAX_LOGIN_ATTEMPTS', 5),
    'lockout_minutes' => (int) env('LOCKOUT_MINUTES', 15),
];
