<?php

namespace App\Providers;

use App\Core\Domain\Repositories\CartRepositoryInterface;
use App\Core\Domain\Repositories\DeliveryRepositoryInterface;
use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Core\Domain\Repositories\SubscriptionRepositoryInterface;
use App\Core\Domain\Repositories\UserRepositoryInterface;
use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Domain\Repositories\VideoRepositoryInterface;
use App\Core\Domain\Services\AuthServiceInterface;
use App\Core\Domain\Services\NotificationServiceInterface;
use App\Core\Domain\Services\OrderServiceInterface;
use App\Core\Domain\Services\PaymentServiceInterface;
use App\Core\Domain\Services\SubscriptionServiceInterface;
use App\Core\Infrastructure\Repositories\EloquentCartRepository;
use App\Core\Infrastructure\Repositories\EloquentDeliveryRepository;
use App\Core\Infrastructure\Repositories\EloquentDriverRepository;
use App\Core\Infrastructure\Repositories\EloquentOrderRepository;
use App\Core\Infrastructure\Repositories\EloquentProductRepository;
use App\Core\Infrastructure\Repositories\EloquentSubscriptionRepository;
use App\Core\Infrastructure\Repositories\EloquentUserRepository;
use App\Core\Infrastructure\Repositories\EloquentVendorRepository;
use App\Core\Infrastructure\Repositories\EloquentVideoRepository;
use App\Core\Infrastructure\Services\JwtAuthService;
use App\Core\Infrastructure\Services\NotificationService;
use App\Core\Infrastructure\Services\OrderProcessingService;
use App\Core\Infrastructure\Services\PaymentService;
use App\Core\Infrastructure\Services\SubscriptionBillingService;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Repositories
        $this->app->bind(UserRepositoryInterface::class, EloquentUserRepository::class);
        $this->app->bind(VendorRepositoryInterface::class, EloquentVendorRepository::class);
        $this->app->bind(ProductRepositoryInterface::class, EloquentProductRepository::class);
        $this->app->bind(OrderRepositoryInterface::class, EloquentOrderRepository::class);
        $this->app->bind(DriverRepositoryInterface::class, EloquentDriverRepository::class);
        $this->app->bind(DeliveryRepositoryInterface::class, EloquentDeliveryRepository::class);
        $this->app->bind(SubscriptionRepositoryInterface::class, EloquentSubscriptionRepository::class);
        $this->app->bind(VideoRepositoryInterface::class, EloquentVideoRepository::class);
        $this->app->bind(CartRepositoryInterface::class, EloquentCartRepository::class);

        // Services
        $this->app->bind(AuthServiceInterface::class, JwtAuthService::class);
        $this->app->bind(OrderServiceInterface::class, OrderProcessingService::class);
        $this->app->bind(PaymentServiceInterface::class, PaymentService::class);
        $this->app->bind(NotificationServiceInterface::class, NotificationService::class);
        $this->app->bind(SubscriptionServiceInterface::class, SubscriptionBillingService::class);
    }
}
