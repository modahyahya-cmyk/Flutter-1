<?php

namespace App\Core\Presentation\API\V1\Middleware;

use Closure;
use Illuminate\Http\Request;

class DriverAuth extends AuthenticateJwt
{
    protected string $requiredRole = 'driver';

    public function handle(Request $request, Closure $next)
    {
        $request->attributes->set('user', $this->authenticate($request));

        return $next($request);
    }
}
