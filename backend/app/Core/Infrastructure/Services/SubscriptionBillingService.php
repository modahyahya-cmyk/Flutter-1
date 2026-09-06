<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Repositories\SubscriptionRepositoryInterface;
use App\Core\Domain\Services\SubscriptionServiceInterface;
use App\Exceptions\BusinessException;
use App\Models\Subscription;
use App\Models\User;

class SubscriptionBillingService implements SubscriptionServiceInterface
{
    public function __construct(private SubscriptionRepositoryInterface $subscriptions)
    {
    }

    public function subscribe(User $user, string $planCode, array $data = []): Subscription
    {
        $plan = $this->subscriptions->findPlanByCode($planCode);

        if ($plan === null || ! $plan->is_active) {
            throw new BusinessException('The selected subscription plan is not available.');
        }

        $existing = $this->subscriptions->activeForUser($user->id);
        if ($existing !== null) {
            throw new BusinessException('You already have an active subscription.');
        }

        $startsAt = now();
        $endsAt = now()->addDays($plan->duration_days);

        return $this->subscriptions->create([
            'plan_id' => $plan->id,
            'user_id' => $user->id,
            'vendor_id' => $data['vendor_id'] ?? null,
            'external_reference' => $data['external_reference'] ?? null,
            'provider' => $data['provider'] ?? 'manual',
            'amount' => $plan->price,
            'status' => $data['status'] ?? 'pending',
            'currency' => config('app_settings.localization.default_currency', 'USD'),
            'starts_at' => $startsAt,
            'ends_at' => $endsAt,
            'next_billing_at' => $endsAt,
        ]);
    }

    public function cancel(User $user, int $subscriptionId): Subscription
    {
        $subscription = $this->subscriptions->findById($subscriptionId);

        if ($subscription === null || $subscription->user_id !== $user->id) {
            throw new BusinessException('Subscription not found.');
        }

        return $this->subscriptions->update($subscription, [
            'status' => 'cancelled',
            'cancelled_at' => now(),
            'next_billing_at' => null,
        ]);
    }

    public function renew(Subscription $subscription): Subscription
    {
        $now = now();

        $endsAt = $now->addDays($subscription->plan->duration_days);

        return $this->subscriptions->update($subscription, [
            'status' => 'active',
            'starts_at' => $now,
            'ends_at' => $endsAt,
            'last_billed_at' => $now,
            'next_billing_at' => $endsAt,
        ]);
    }

    public function processExpiringSubscriptions(): int
    {
        $expiring = $this->subscriptions->expiringSoon(1);
        $count = 0;

        foreach ($expiring as $subscription) {
            if ($subscription->ends_at === null || $subscription->ends_at->isPast()) {
                $this->subscriptions->update($subscription, ['status' => 'expired']);
                $count++;
            } else {
                $this->subscriptions->update($subscription, ['status' => 'expired']);
                $count++;
            }
        }

        return $count;
    }

    public function getActivePlan(User $user): ?Subscription
    {
        return $this->subscriptions->activeForUser($user->id);
    }

    public function isVendorSubscribed(int $vendorId): bool
    {
        return $this->subscriptions->activeForVendor($vendorId) !== null;
    }
}
