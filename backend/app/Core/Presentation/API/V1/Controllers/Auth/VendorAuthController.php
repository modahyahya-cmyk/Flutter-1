<?php

namespace App\Core\Presentation\API\V1\Controllers\Auth;

use App\Core\Domain\Services\AuthServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Requests\Auth\LoginRequest;
use App\Core\Presentation\API\V1\Requests\Auth\RegisterRequest;
use App\Core\Presentation\API\V1\Resources\VendorResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorAuthController extends BaseController
{
    public function __construct(private AuthServiceInterface $authService)
    {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->authService->register($request->validated(), 'vendor');

        return $this->success($result, 'Vendor account created. Awaiting approval.', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login(
            $request->validated('identifier'),
            $request->validated('password'),
            'vendor'
        );

        return $this->success($result, 'Logged in successfully.');
    }

    public function refresh(Request $request): JsonResponse
    {
        $result = $this->authService->refresh((string) $request->input('refresh_token', ''));

        return $this->success($result, 'Token refreshed.');
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->attributes->get('user')->load('vendor');

        return $this->success(VendorResource::make($user->vendor));
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->attributes->get('user'));

        return $this->success(null, 'Logged out successfully.');
    }
}
