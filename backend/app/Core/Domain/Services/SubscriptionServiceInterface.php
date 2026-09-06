<?php

namespace App\Core\Domain\Services;

use App\Models\Subscription;
use App\Models\User;

interface SubscriptionServiceInterface
{
    public function subscribe(User $user, string $planCode, array $data = []): Subscription;

    public function cancel(User $user, int $subscriptionId): Subscription;

    public function renew(Subscription $subscription): Subscription;

    public function processExpiringSubscriptions(): int;

    public function getActivePlan(User $user): ?Subscription;

    public function isVendorSubscribed(int $vendorId): bool;
}
