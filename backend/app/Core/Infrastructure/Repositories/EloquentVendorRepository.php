<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Models\Vendor;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentVendorRepository implements VendorRepositoryInterface
{
    public function findById(int $id): ?Vendor
    {
        return Vendor::with('user')->find($id);
    }

    public function findByUserId(int $userId): ?Vendor
    {
        return Vendor::where('user_id', $userId)->first();
    }

    public function findBySlug(string $slug): ?Vendor
    {
        return Vendor::where('slug', $slug)->with('user', 'branches')->first();
    }

    public function findByEmail(string $email): ?Vendor
    {
        return Vendor::where('business_email', $email)->first();
    }

    public function create(array $data): Vendor
    {
        return Vendor::create($data);
    }

    public function update(Vendor $vendor, array $data): Vendor
    {
        $vendor->update($data);

        return $vendor->fresh();
    }

    public function delete(Vendor $vendor): bool
    {
        return (bool) $vendor->delete();
    }

    public function approve(Vendor $vendor): Vendor
    {
        $vendor->update([
            'status' => 'approved',
            'rejection_reason' => null,
            'is_verified' => true,
            'approved_at' => now(),
        ]);

        return $vendor->fresh();
    }

    public function reject(Vendor $vendor, string $reason): Vendor
    {
        $vendor->update([
            'status' => 'rejected',
            'rejection_reason' => $reason,
        ]);

        return $vendor->fresh();
    }

    public function suspend(Vendor $vendor): Vendor
    {
        $vendor->update(['status' => 'suspended']);

        return $vendor->fresh();
    }

    public function paginate(int $perPage = 15, string $search = null, string $status = null): LengthAwarePaginator
    {
        $query = Vendor::with('user');

        if ($status !== null) {
            $query->where('status', $status);
        }

        if ($search !== null) {
            $query->where(function ($q) use ($search) {
                $q->where('business_name', 'like', "%{$search}%")
                    ->orWhere('business_email', 'like', "%{$search}%")
                    ->orWhere('slug', 'like', "%{$search}%");
            });
        }

        return $query->latest()->paginate($perPage);
    }

    public function countPending(): int
    {
        return Vendor::where('status', 'pending')->count();
    }

    public function isPendingApproval(string $slug): bool
    {
        return Vendor::where('slug', $slug)->where('status', 'pending')->exists();
    }
}
