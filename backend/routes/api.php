<?php

use App\Core\Presentation\API\V1\Controllers\Admin\AdminAuthController;
use App\Core\Presentation\API\V1\Controllers\Admin\DashboardController;
use App\Core\Presentation\API\V1\Controllers\Admin\DriverApprovalController;
use App\Core\Presentation\API\V1\Controllers\Admin\UserManagementController;
use App\Core\Presentation\API\V1\Controllers\Admin\VendorApprovalController;
use App\Core\Presentation\API\V1\Controllers\Auth\CustomerAuthController;
use App\Core\Presentation\API\V1\Controllers\Auth\DriverAuthController;
use App\Core\Presentation\API\V1\Controllers\Auth\VendorAuthController;
use App\Core\Presentation\API\V1\Controllers\Customer\CartController;
use App\Core\Presentation\API\V1\Controllers\Customer\OrderController;
use App\Core\Presentation\API\V1\Controllers\Customer\PaymentController;
use App\Core\Presentation\API\V1\Controllers\Customer\ProductController;
use App\Core\Presentation\API\V1\Controllers\Customer\ProfileController;
use App\Core\Presentation\API\V1\Controllers\Customer\SubscriptionController;
use App\Core\Presentation\API\V1\Controllers\Customer\VideoController;
use App\Core\Presentation\API\V1\Controllers\Driver\DeliveryController;
use App\Core\Presentation\API\V1\Controllers\Driver\EarningsController as DriverEarningsController;
use App\Core\Presentation\API\V1\Controllers\Driver\LocationController;
use App\Core\Presentation\API\V1\Controllers\Vendor\BranchController;
use App\Core\Presentation\API\V1\Controllers\Vendor\OrderManagementController;
use App\Core\Presentation\API\V1\Controllers\Vendor\ProductManagementController;
use App\Core\Presentation\API\V1\Middleware\AdminAuth;
use App\Core\Presentation\API\V1\Middleware\CustomerAuth;
use App\Core\Presentation\API\V1\Middleware\DriverAuth;
use App\Core\Presentation\API\V1\Middleware\SanitizeInput;
use App\Core\Presentation\API\V1\Middleware\VendorAuth;
use App\Core\Presentation\API\V1\Controllers\Webhook\StripeWebhookController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->middleware('throttle:api')->group(function () {

    // --- Health check ---
    Route::get('/health', fn () => response()->json([
        'success' => true,
        'status' => 'ok',
        'time' => now()->toIso8601String(),
    ]));

    // --- Payment webhooks (provider-signed; signature verified server-side) ---
    Route::post('/webhooks/stripe', [StripeWebhookController::class, 'handle']);

    // --- Public product browsing ---
    Route::prefix('products')->group(function () {
        Route::get('/', [ProductController::class, 'index'])->middleware(SanitizeInput::class);
        Route::get('/featured', [ProductController::class, 'featured']);
        Route::get('/best-sellers', [ProductController::class, 'bestSellers']);
        Route::get('/search', [ProductController::class, 'search']);
        Route::get('/{product}', [ProductController::class, 'show']);
    });

    // --- Public videos ---
    Route::get('/videos', [VideoController::class, 'index']);
    Route::get('/videos/{id}', [VideoController::class, 'show']);

    // --- Customer auth (stricter throttle for credential attacks) ---
    Route::prefix('customer/auth')->middleware('throttle:auth')->group(function () {
        Route::post('/register', [CustomerAuthController::class, 'register']);
        Route::post('/login', [CustomerAuthController::class, 'login']);
        Route::post('/refresh', [CustomerAuthController::class, 'refresh']);
    });

    // --- Vendor auth ---
    Route::prefix('vendor/auth')->middleware('throttle:auth')->group(function () {
        Route::post('/register', [VendorAuthController::class, 'register']);
        Route::post('/login', [VendorAuthController::class, 'login']);
        Route::post('/refresh', [VendorAuthController::class, 'refresh']);
    });

    // --- Driver auth ---
    Route::prefix('driver/auth')->middleware('throttle:auth')->group(function () {
        Route::post('/register', [DriverAuthController::class, 'register']);
        Route::post('/login', [DriverAuthController::class, 'login']);
        Route::post('/refresh', [DriverAuthController::class, 'refresh']);
    });

    // --- Admin auth ---
    Route::prefix('admin/auth')->middleware('throttle:auth')->group(function () {
        Route::post('/login', [AdminAuthController::class, 'login']);
        Route::post('/refresh', [AdminAuthController::class, 'refresh']);
    });

    // ================== CUSTOMER (authenticated) ==================
    Route::prefix('customer')->middleware([CustomerAuth::class, SanitizeInput::class])->group(function () {
        Route::post('/auth/logout', [CustomerAuthController::class, 'logout']);
        Route::get('/profile', [CustomerAuthController::class, 'me']);
        Route::post('/profile', [ProfileController::class, 'update']);
        Route::post('/profile/password', [ProfileController::class, 'changePassword']);
        Route::delete('/profile/avatar', [ProfileController::class, 'deleteAvatar']);

        Route::get('/cart', [CartController::class, 'show']);
        Route::post('/cart/items', [CartController::class, 'add']);
        Route::put('/cart/items/{cartItem}', [CartController::class, 'update']);
        Route::delete('/cart/items/{cartItem}', [CartController::class, 'remove']);
        Route::delete('/cart', [CartController::class, 'clear']);

        Route::get('/orders', [OrderController::class, 'index']);
        Route::post('/orders', [OrderController::class, 'store']);
        Route::get('/orders/{id}', [OrderController::class, 'show']);
        Route::post('/orders/{id}/cancel', [OrderController::class, 'cancel']);

        Route::post('/payments', [PaymentController::class, 'initialize']);
        Route::get('/payments/{reference}', [PaymentController::class, 'show']);

        Route::get('/videos/{id}/like', [VideoController::class, 'like']);

        Route::get('/subscriptions/plans', [SubscriptionController::class, 'plans']);
        Route::post('/subscriptions', [SubscriptionController::class, 'subscribe']);
        Route::get('/subscriptions/me', [SubscriptionController::class, 'mySubscription']);
        Route::post('/subscriptions/{id}/cancel', [SubscriptionController::class, 'cancel']);
    });

    // ================== VENDOR ==================
    // Profile/logout need only authentication (a pending/suspended vendor can
    // still see their approval status). Operational routes additionally require
    // an APPROVED vendor profile (centralized via the approved.vendor
    // middleware), so pending/rejected/suspended vendors cannot operate.
    Route::prefix('vendor')->middleware([VendorAuth::class, SanitizeInput::class])->group(function () {
        Route::post('/auth/logout', [VendorAuthController::class, 'logout']);
        Route::get('/profile', [VendorAuthController::class, 'me']);

        Route::middleware('approved.vendor')->group(function () {
            Route::get('/products', [ProductManagementController::class, 'index']);
            Route::post('/products', [ProductManagementController::class, 'store']);
            Route::put('/products/{id}', [ProductManagementController::class, 'update']);
            Route::delete('/products/{id}', [ProductManagementController::class, 'destroy']);
            Route::patch('/products/{id}/toggle-active', [ProductManagementController::class, 'toggleActive']);

            Route::get('/orders', [OrderManagementController::class, 'index']);
            Route::get('/orders/{id}', [OrderManagementController::class, 'show']);
            Route::patch('/orders/{id}/status', [OrderManagementController::class, 'updateStatus']);

            Route::get('/branches', [BranchController::class, 'index']);
            Route::post('/branches', [BranchController::class, 'store']);
            Route::put('/branches/{id}', [BranchController::class, 'update']);
            Route::delete('/branches/{id}', [BranchController::class, 'destroy']);
        });
    });

    // ================== DRIVER ==================
    // Profile/logout need only authentication; operational routes additionally
    // require an APPROVED driver profile (centralized via the approved.driver
    // middleware) so pending/rejected/suspended drivers cannot operate.
    Route::prefix('driver')->middleware([DriverAuth::class])->group(function () {
        Route::post('/auth/logout', [DriverAuthController::class, 'logout']);
        Route::get('/profile', [DriverAuthController::class, 'me']);

        Route::middleware('approved.driver')->group(function () {
            Route::get('/deliveries', [DeliveryController::class, 'mine']);
            Route::get('/deliveries/available', [DeliveryController::class, 'available']);
            Route::post('/deliveries/{orderId}/accept', [DeliveryController::class, 'accept']);
            Route::patch('/deliveries/{id}/status', [DeliveryController::class, 'updateStatus']);

            Route::put('/location', [LocationController::class, 'update']);
            Route::put('/location/online', [LocationController::class, 'setOnline']);
            Route::post('/location/batch', [LocationController::class, 'storeBatch']);

            Route::get('/earnings', [DriverEarningsController::class, 'summary']);
        });
    });

    // ================== ADMIN (authenticated, admin role) ==================
    Route::prefix('admin')->middleware([AdminAuth::class])->group(function () {
        Route::post('/auth/logout', [AdminAuthController::class, 'logout']);
        Route::get('/profile', [AdminAuthController::class, 'me']);

        Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
        Route::get('/dashboard/revenue', [DashboardController::class, 'revenueByMonth']);

        Route::get('/users', [UserManagementController::class, 'index']);
        Route::patch('/users/{id}/block', [UserManagementController::class, 'block']);
        Route::patch('/users/{id}/unblock', [UserManagementController::class, 'unblock']);

        Route::get('/vendors', [VendorApprovalController::class, 'index']);
        Route::patch('/vendors/{id}/approve', [VendorApprovalController::class, 'approve']);
        Route::patch('/vendors/{id}/reject', [VendorApprovalController::class, 'reject']);
        Route::patch('/vendors/{id}/suspend', [VendorApprovalController::class, 'suspend']);

        Route::get('/drivers', [DriverApprovalController::class, 'index']);
        Route::patch('/drivers/{id}/approve', [DriverApprovalController::class, 'approve']);
        Route::patch('/drivers/{id}/reject', [DriverApprovalController::class, 'reject']);

        Route::post('/payments/{payment}/refund', [PaymentController::class, 'refund']);
    });
});
