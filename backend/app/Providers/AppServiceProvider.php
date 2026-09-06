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
        Model::preventLazyLoading(! $this->app->isProduction());
        Model::unguard(false);

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
