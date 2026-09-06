<?php

namespace App\Core\Presentation\API\V1\Controllers\Admin;

use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Repositories\SubscriptionRepositoryInterface;
use App\Core\Domain\Repositories\UserRepositoryInterface;
use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use Illuminate\Http\JsonResponse;

class DashboardController extends BaseController
{
    public function __construct(
        private UserRepositoryInterface $users,
        private VendorRepositoryInterface $vendors,
        private DriverRepositoryInterface $drivers,
        private OrderRepositoryInterface $orders,
        private SubscriptionRepositoryInterface $subscriptions,
    ) {
    }

    public function stats(): JsonResponse
    {
        return $this->success([
            'total_customers' => $this->users->countByRole('customer'),
            'total_vendors' => $this->users->countByRole('vendor'),
            'pending_vendors' => $this->vendors->countPending(),
            'total_drivers' => $this->users->countByRole('driver'),
            'drivers_online' => $this->drivers->countOnline(),
            'total_orders' => $this->orders->countByStatus('confirmed'),
            'revenue' => $this->orders->sumRevenue(),
            'active_subscriptions' => $this->subscriptions->countActive(),
        ]);
    }

    public function revenueByMonth(int $months = 6): JsonResponse
    {
        $orders = \App\Models\Order::where('payment_status', 'completed')
            ->where('created_at', '>=', now()->subMonths($months))
            ->get();

        $rows = $orders->groupBy(fn ($o) => $o->created_at->format('Y-m'))
            ->map(fn ($group) => [
                'month' => $group->first()->created_at->format('F Y'),
                'revenue' => (float) $group->sum('total_amount'),
                'orders' => $group->count(),
            ])
            ->values();

        return $this->success($rows);
    }
}
