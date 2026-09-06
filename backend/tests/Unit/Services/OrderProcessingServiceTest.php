<?php

namespace Tests\Unit\Services;

use App\Core\Infrastructure\Services\OrderProcessingService;
use Tests\TestCase;

class OrderProcessingServiceTest extends TestCase
{
    public function test_calculate_totals_returns_correct_math(): void
    {
        $items = [
            ['total' => 40.00],
            ['total' => 60.00],
        ];

        config(['app_settings.business.commission_rate' => 15]);
        config(['app_settings.business.delivery_fee_type' => 'distance']);
        config(['app_settings.business.base_delivery_fee' => 5]);
        config(['app_settings.business.per_km_rate' => 0.5]);

        $service = new OrderProcessingService(
            \Mockery::mock(\App\Core\Domain\Repositories\OrderRepositoryInterface::class),
            \Mockery::mock(\App\Core\Domain\Repositories\ProductRepositoryInterface::class),
            \Mockery::mock(\App\Core\Domain\Repositories\DeliveryRepositoryInterface::class),
            \Mockery::mock(\App\Core\Domain\Repositories\DriverRepositoryInterface::class),
            \Mockery::mock(\App\Core\Domain\Services\NotificationServiceInterface::class),
        );

        $totals = $service->calculateTotals($items, ['distance_km' => 10]);

        $this->assertSame(100.0, $totals['subtotal']);
        // delivery fee = 5 + 10*0.5 = 10
        $this->assertSame(10.0, $totals['delivery_fee']);
        // tax = 5% of 100 = 5
        $this->assertSame(5.0, $totals['tax']);
        // total = 100 + 10 + 5 = 115
        $this->assertSame(115.0, $totals['total']);
        // commission = 15% of 100 = 15
        $this->assertSame(15.0, $totals['commission']);
        // vendor amount = 85
        $this->assertSame(85.0, $totals['vendor_amount']);
    }
}
