<?php

namespace App\Core\Domain\Repositories;

use App\Models\Subscription;
use App\Models\SubscriptionPlan;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface SubscriptionRepositoryInterface
{
    public function findById(int $id): ?Subscription;

    public function findPlans(bool $activeOnly = true): \Illuminate\Support\Collection;

    public function findPlanByCode(string $code): ?SubscriptionPlan;

    public function create(array $data): Subscription;

    public function update(Subscription $subscription, array $data): Subscription;

    public function activeForUser(int $userId): ?Subscription;

    public function activeForVendor(int $vendorId): ?Subscription;

    public function paginate(int $perPage = 15): LengthAwarePaginator;

    public function expiringSoon(int $days = 3): array;

    public function countActive(): int;
}
