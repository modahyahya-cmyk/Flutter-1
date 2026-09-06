<?php

namespace App\Core\Presentation\API\V1\Middleware;

use Closure;
use Illuminate\Http\Request;

class CustomerAuth extends AuthenticateJwt
{
    protected string $requiredRole = 'customer';

    public function handle(Request $request, Closure $next)
    {
        $request->attributes->set('user', $this->authenticate($request));

        return $next($request);
    }
}
