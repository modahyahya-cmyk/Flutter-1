<?php

namespace App\Core\Presentation\API\V1\Middleware;

use Closure;
use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Exceptions\UnauthorizedException;
use Illuminate\Http\Request;

/**
 * Central authorization for driver operational actions. Only an APPROVED
 * driver profile may view/accept deliveries, update location or view
 * earnings. Pending, rejected and suspended drivers are blocked here so the
 * rule is enforced once, not per endpoint.
 */
class DriverApproved
{
    public function __construct(private DriverRepositoryInterface $drivers)
    {
    }

    public function handle(Request $request, Closure $next)
    {
        $user = $request->attributes->get('user');
        $driver = $this->drivers->findByUserId($user->id);

        if ($driver === null) {
            throw new UnauthorizedException('No driver profile is linked to this account.', 403);
        }

        if ($driver->status !== 'approved') {
            throw new UnauthorizedException('Your driver account is not approved. Operational actions are disabled.', 403);
        }

        $request->attributes->set('driver', $driver);

        return $next($request);
    }
}
