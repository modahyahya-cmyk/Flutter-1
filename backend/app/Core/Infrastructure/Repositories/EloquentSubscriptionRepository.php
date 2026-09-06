<?php

namespace App\Core\Infrastructure\Repositories;

use App\Core\Domain\Repositories\SubscriptionRepositoryInterface;
use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class EloquentSubscriptionRepository implements SubscriptionRepositoryInterface
{
    public function findById(int $id): ?Subscription
    {
        return Subscription::with(['plan', 'user'])->find($id);
    }

    public function findPlans(bool $activeOnly = true): Collection
    {
        $query = SubscriptionPlan::query();

        if ($activeOnly) {
            $query->where('is_active', true);
        }

        return $query->orderBy('sort_order')->get();
    }

    public function findPlanByCode(string $code): ?SubscriptionPlan
    {
        return SubscriptionPlan::where('code', $code)->first();
    }

    public function create(array $data): Subscription
    {
        return Subscription::create($data);
    }

    public function update(Subscription $subscription, array $data): Subscription
    {
        $subscription->update($data);

        return $subscription->fresh();
    }

    public function activeForUser(int $userId): ?Subscription
    {
        return Subscription::where('user_id', $userId)
            ->where('status', 'active')
            ->latest()
            ->first();
    }

    public function activeForVendor(int $vendorId): ?Subscription
    {
        return Subscription::where('vendor_id', $vendorId)
            ->where('status', 'active')
            ->latest()
            ->first();
    }

    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return Subscription::with(['plan', 'user'])
            ->latest()
            ->paginate($perPage);
    }

    public function expiringSoon(int $days = 3): array
    {
        return Subscription::where('status', 'active')
            ->whereBetween('ends_at', [now(), now()->addDays($days)])
            ->with(['plan', 'vendor'])
            ->get()
            ->all();
    }

    public function countActive(): int
    {
        return Subscription::where('status', 'active')->count();
    }
}
