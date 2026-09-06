<?php

namespace App\Core\Presentation\API\V1\Controllers\Admin;

use App\Core\Domain\Repositories\UserRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\UserResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserManagementController extends BaseController
{
    public function __construct(private UserRepositoryInterface $users)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            UserResource::collection($this->users->paginate(
                min($perPage, 100),
                $request->query('search'),
                $request->query('role')
            ))
        );
    }

    public function block(Request $request, int $id): JsonResponse
    {
        $user = $this->users->findById($id);
        abort_if($user === null, 404, 'User not found.');

        $user = $this->users->update($user, ['status' => 'banned']);

        return $this->success(UserResource::make($user), 'User blocked.');
    }

    public function unblock(int $id): JsonResponse
    {
        $user = $this->users->findById($id);
        abort_if($user === null, 404, 'User not found.');

        $user = $this->users->update($user, ['status' => 'active']);

        return $this->success(UserResource::make($user), 'User unblocked.');
    }
}
