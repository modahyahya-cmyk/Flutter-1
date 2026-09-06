<?php

namespace App\Core\Domain\Repositories;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface UserRepositoryInterface
{
    public function findById(int $id): ?User;

    public function findByEmail(string $email): ?User;

    public function findByPhone(string $phone): ?User;

    public function create(array $data): User;

    public function update(User $user, array $data): User;

    public function delete(User $user): bool;

    public function paginate(int $perPage = 15, string $search = null, string $role = null): LengthAwarePaginator;

    public function updateLastLogin(User $user): void;

    public function countByRole(string $role): int;
}
