<?php

namespace App\Core\Domain\Repositories;

use App\Models\Vendor;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface VendorRepositoryInterface
{
    public function findById(int $id): ?Vendor;

    public function findByUserId(int $userId): ?Vendor;

    public function findBySlug(string $slug): ?Vendor;

    public function findByEmail(string $email): ?Vendor;

    public function create(array $data): Vendor;

    public function update(Vendor $vendor, array $data): Vendor;

    public function delete(Vendor $vendor): bool;

    public function approve(Vendor $vendor): Vendor;

    public function reject(Vendor $vendor, string $reason): Vendor;

    public function suspend(Vendor $vendor): Vendor;

    public function paginate(int $perPage = 15, string $search = null, string $status = null): LengthAwarePaginator;

    public function countPending(): int;

    public function isPendingApproval(string $slug): bool;
}
