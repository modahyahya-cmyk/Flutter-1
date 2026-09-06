<?php

namespace App\Core\Presentation\API\V1\Controllers\Auth;

use App\Core\Domain\Services\AuthServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Requests\Auth\LoginRequest;
use App\Core\Presentation\API\V1\Requests\Auth\RegisterRequest;
use App\Core\Presentation\API\V1\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerAuthController extends BaseController
{
    public function __construct(private AuthServiceInterface $authService)
    {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->authService->register($request->validated(), 'customer');

        return $this->success($this->loginResponse($result), 'Account created successfully.', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login(
            $request->validated('identifier'),
            $request->validated('password'),
            'customer'
        );

        return $this->success($this->loginResponse($result), 'Logged in successfully.');
    }

    public function refresh(Request $request): JsonResponse
    {
        $result = $this->authService->refresh((string) $request->input('refresh_token', ''));

        return $this->success($this->loginResponse($result), 'Token refreshed.');
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->attributes->get('user');

        return $this->success(UserResource::make($user->load('vendor', 'driver')));
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->attributes->get('user'));

        return $this->success(null, 'Logged out successfully.');
    }

    private function loginResponse(array $result): array
    {
        return [
            'access_token' => $result['access_token'],
            'refresh_token' => $result['refresh_token'],
            'token_type' => $result['token_type'],
            'expires_in' => $result['expires_in'],
            'user' => $result['user'],
        ];
    }
}
