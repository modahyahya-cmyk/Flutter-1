# Security Best Practices

## Backend

1. **Environment** — keep `APP_DEBUG=false` in production. Never commit `.env`.
2. **Auth** — JWT tokens are short-lived with refresh rotation; use the
   `sanctum`/JWT guard middleware on every protected route.
3. **Validate input** — every endpoint is backed by a `FormRequest`.
4. **Middleware** — built-in rate limiting, input sanitization (XSS) and role
   checks are already wired.
5. **Headers** — `X-Frame-Options`, `X-Content-Type-Options` configured in the
   deployment guide.
6. **Secrets** — payment / SMS credentials live only in `.env` and CI secrets.
7. **HTTPS** — enforce TLS (see nginx + certbot in the installation guide).
8. **Dependencies** — `composer audit` before shipping; update promptly.

## Flutter apps

1. **Storage** — tokens are kept in `flutter_secure_storage`
   (Android encrypted shared preferences); non-sensitive caches use
   `SharedPreferences`.
2. **No secrets in code** — API keys are injected at build time via
   `--dart-define` (e.g. `API_URL`, `GOOGLE_MAPS_KEY`).
3. **Injection safety** — no raw SQL / no webview eval of user input.
4. **TLS** — the Dio client pins to `https` base URLs.
5. **Logging** — HTTP logging is gated behind `AppConfig.ENABLE_API_LOGGING`
   (`DEBUG_MODE`) so it is silent in release builds.

## Secrets scanning

The `pr-checks.yml` workflow runs TruffleHog over every PR to block accidental
secret commits. Commit `.env.example` but never `.env`.

## Local data

The driver and vendor apps encrypt sensitive material at rest (secure storage)
and store only non-sensitive offline caches to disk. A "clear all data" hook is
available in `IsarService.clearAllData()` for a user-triggered privacy reset.
