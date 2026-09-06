<?php

namespace Database\Seeders;

use App\Models\SubscriptionPlan;
use Illuminate\Database\Seeder;

class SubscriptionPlanSeeder extends Seeder
{
    public function run(): void
    {
        $plans = [
            [
                'name' => 'Starter',
                'code' => 'starter',
                'price' => 0,
                'billing_cycle' => 'monthly',
                'duration_days' => 30,
                'featured' => false,
                'commission_rate' => 15,
                'features' => ['1 store', '50 products', 'Basic analytics'],
                'sort_order' => 1,
            ],
            [
                'name' => 'Growth',
                'code' => 'growth',
                'price' => 49,
                'billing_cycle' => 'monthly',
                'duration_days' => 30,
                'featured' => true,
                'commission_rate' => 10,
                'features' => ['Unlimited products', 'Multi-branch', 'Video commerce', 'Advanced analytics'],
                'sort_order' => 2,
            ],
            [
                'name' => 'Enterprise',
                'code' => 'enterprise',
                'price' => 199,
                'billing_cycle' => 'monthly',
                'duration_days' => 30,
                'featured' => false,
                'commission_rate' => 5,
                'features' => ['Everything in Growth', 'Priority support', 'Dedicated account manager'],
                'sort_order' => 3,
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::updateOrCreate(['code' => $plan['code']], $plan);
        }
    }
}
