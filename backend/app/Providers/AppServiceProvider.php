<?php

namespace App\Providers;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Cache\RateLimiting\Limit;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
    }

    public function boot(): void
    {
        // Eloquent models stay mass-assignment guarded by default; in
        // non-production environments lazy loading also raises an exception
        // so N+1 / missing-eager-load bugs surface in development.
        Model::preventLazyLoading(! $this->app->isProduction());

        RateLimiter::for('api', function (Request $request) {
            $limit = (int) config('app_settings.security.rate_limit_per_minute', 60);

            return Limit::perMinute($limit)->by($request->user()?->id ?: $request->ip());
        });

        // Stricter limit for unauthenticated auth endpoints (login / register /
        // refresh) to mitigate credential stuffing / brute-force attacks.
        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(10)->by($request->ip());
        });
    }
}
