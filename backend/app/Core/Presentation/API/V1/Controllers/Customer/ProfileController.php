<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\UserRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends BaseController
{
    public function __construct(private UserRepositoryInterface $users)
    {
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'first_name' => ['sometimes', 'string', 'max:100'],
            'last_name' => ['sometimes', 'string', 'max:100'],
            'phone' => ['sometimes', 'string', 'max:20'],
            'avatar' => ['nullable', 'string', 'url', 'max:500'],
            'language' => ['sometimes', 'string', 'in:en,es,fr,de,ar'],
            'timezone' => ['sometimes', 'string', 'max:50'],
            'email_notifications' => ['sometimes', 'boolean'],
            'push_notifications' => ['sometimes', 'boolean'],
            'sms_notifications' => ['sometimes', 'boolean'],
        ]);

        $user = $this->users->update($request->attributes->get('user'), $validated);

        return $this->success(UserResource::make($user));
    }

    public function changePassword(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = $request->attributes->get('user');

        if (! app('hash')->check($validated['current_password'], $user->password)) {
            return $this->success(null, 'Current password is incorrect.', 422);
        }

        $this->users->update($user, ['password' => $validated['password']]);

        return $this->success(null, 'Password changed successfully.');
    }

    public function deleteAvatar(Request $request): JsonResponse
    {
        $user = $this->users->update($request->attributes->get('user'), ['avatar' => null]);

        return $this->success(UserResource::make($user), 'Avatar removed.');
    }
}
