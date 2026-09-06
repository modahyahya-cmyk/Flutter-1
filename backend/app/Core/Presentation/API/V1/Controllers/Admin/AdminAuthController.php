<?php

namespace App\Core\Presentation\API\V1\Controllers\Admin;

use App\Core\Domain\Services\AuthServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Requests\Auth\LoginRequest;
use App\Core\Presentation\API\V1\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminAuthController extends BaseController
{
    public function __construct(private AuthServiceInterface $authService)
    {
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login(
            $request->validated('identifier'),
            $request->validated('password'),
            'admin'
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
        return $this->success(UserResource::make($request->attributes->get('user')));
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->attributes->get('user'));

        return $this->success(null, 'Logged out successfully.');
    }
}
