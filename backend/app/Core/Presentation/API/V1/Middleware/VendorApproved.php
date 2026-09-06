<?php

namespace App\Core\Presentation\API\V1\Middleware;

use Closure;
use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Exceptions\UnauthorizedException;
use Illuminate\Http\Request;

/**
 * Central authorization for vendor operational actions. Only an APPROVED
 * vendor profile may perform product / order / branch operations. Pending,
 * rejected and suspended vendors are blocked here, not in individual
 * controllers, so the rule cannot be bypassed per-endpoint.
 */
class VendorApproved
{
    public function __construct(private VendorRepositoryInterface $vendors)
    {
    }

    public function handle(Request $request, Closure $next)
    {
        $user = $request->attributes->get('user');
        $vendor = $this->vendors->findByUserId($user->id);

        if ($vendor === null) {
            throw new UnauthorizedException('No vendor profile is linked to this account.', 403);
        }

        if ($vendor->status !== 'approved') {
            throw new UnauthorizedException('Your vendor account is not approved. Operational actions are disabled.', 403);
        }

        $request->attributes->set('vendor', $vendor);

        return $next($request);
    }
}
