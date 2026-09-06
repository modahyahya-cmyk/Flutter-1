<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\SubscriptionRepositoryInterface;
use App\Core\Domain\Services\SubscriptionServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Requests\Subscription\CreateSubscriptionRequest;
use App\Core\Presentation\API\V1\Resources\SubscriptionPlanResource;
use App\Core\Presentation\API\V1\Resources\SubscriptionResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubscriptionController extends BaseController
{
    public function __construct(
        private SubscriptionServiceInterface $subscriptionService,
        private SubscriptionRepositoryInterface $subscriptions,
    ) {
    }

    public function plans(): JsonResponse
    {
        return $this->success(
            SubscriptionPlanResource::collection($this->subscriptions->findPlans(true))
        );
    }

    public function subscribe(CreateSubscriptionRequest $request): JsonResponse
    {
        $user = $request->attributes->get('user');
        $subscription = $this->subscriptionService->subscribe(
            $user,
            $request->validated('plan_code'),
            $request->only('provider', 'external_reference')
        );

        return $this->success(SubscriptionResource::make($subscription->load('plan')), 'Subscription created.', 201);
    }

    public function mySubscription(Request $request): JsonResponse
    {
        $user = $request->attributes->get('user');
        $subscription = $this->subscriptionService->getActivePlan($user);

        return $this->success(
            $subscription ? SubscriptionResource::make($subscription->load('plan')) : null
        );
    }

    public function cancel(Request $request, int $id): JsonResponse
    {
        $user = $request->attributes->get('user');
        $subscription = $this->subscriptionService->cancel($user, $id);

        return $this->success(SubscriptionResource::make($subscription->load('plan')), 'Subscription cancelled.');
    }
}
