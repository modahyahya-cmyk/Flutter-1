<?php

namespace App\Core\Infrastructure\Services;

use App\Core\Domain\Repositories\DeliveryRepositoryInterface;
use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Core\Domain\Services\NotificationServiceInterface;
use App\Core\Domain\Services\OrderServiceInterface;
use App\Core\Domain\State\DeliveryStateMachine;
use App\Core\Domain\State\OrderStateMachine;
use App\Exceptions\BusinessException;
use App\Models\Delivery;
use App\Models\Driver;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderProcessingService implements OrderServiceInterface
{
    public function __construct(
        private OrderRepositoryInterface $orders,
        private ProductRepositoryInterface $products,
        private DeliveryRepositoryInterface $deliveries,
        private DriverRepositoryInterface $drivers,
        private NotificationServiceInterface $notifications,
    ) {
    }

    public function createOrder(User $customer, array $data): Order
    {
        $totals = $this->calculateTotals($data['items'], $data);

        if ($totals['subtotal'] < (float) config('app_settings.business.min_order_amount', 10)) {
            throw new BusinessException('Order subtotal is below the minimum order amount.');
        }

        // Idempotency: a retried request carrying the same key returns the
        // already-created order instead of creating a duplicate.
        $key = trim((string) ($data['idempotency_key'] ?? ''));
        if ($key !== '') {
            $existing = Order::where('customer_id', $customer->id)
                ->where('idempotency_key', $key)
                ->with('items')
                ->first();
            if ($existing !== null) {
                return $existing;
            }
        }

        try {
            return DB::transaction(function () use ($customer, $data, $totals, $key) {
            $order = $this->orders->create([
                'order_number' => $this->generateOrderNumber(),
                'idempotency_key' => $key !== '' ? $key : null,
                'customer_id' => $customer->id,
                'vendor_id' => $data['vendor_id'],
                'branch_id' => $data['branch_id'] ?? null,
                'order_type' => $data['order_type'] ?? 'delivery',
                'subtotal' => $totals['subtotal'],
                'tax_amount' => $totals['tax'],
                'delivery_fee' => $totals['delivery_fee'],
                'discount_amount' => $totals['discount'],
                'total_amount' => $totals['total'],
                'commission_amount' => $totals['commission'],
                'vendor_earnings' => $totals['vendor_amount'],
                'payment_method' => $data['payment_method'] ?? config('app_settings.payment_gateways.default', 'stripe'),
                'customer_notes' => $data['customer_notes'] ?? null,
                'delivery_address' => $data['delivery_address'] ?? null,
                'delivery_latitude' => $data['customer_latitude'] ?? null,
                'delivery_longitude' => $data['customer_longitude'] ?? null,
                'delivery_distance_km' => $data['distance_km'] ?? null,
                'status' => OrderStateMachine::PENDING,
                'payment_status' => 'pending',
            ]);

            foreach ($data['items'] as $item) {
                $order->items()->create([
                    'product_id' => $item['product_id'],
                    'variant_id' => $item['variant_id'] ?? null,
                    'product_name' => $item['product_name'],
                    'variant_name' => $item['variant_name'] ?? null,
                    'unit_price' => $item['unit_price'],
                    'quantity' => $item['quantity'],
                    'total_amount' => $item['total_amount'],
                    'commission_amount' => round($item['total_amount'] * $totals['commission_rate'] / 100, 2),
                    'vendor_earnings' => round($item['total_amount'] * (100 - $totals['commission_rate']) / 100, 2),
                ]);

                $this->decrementStockSafely((int) $item['product_id'], (int) $item['quantity']);
            }

            return $order->load('items');
        });
        } catch (\Throwable $e) {
            // A concurrent duplicate racing on the same idempotency key hits the
            // unique index; return the already-created order instead of failing.
            if ($key !== '' && $this->isIdempotencyConflict($e)) {
                $existing = Order::where('customer_id', $customer->id)
                    ->where('idempotency_key', $key)
                    ->with('items')
                    ->first();
                if ($existing !== null) {
                    return $existing;
                }
            }
            throw $e;
        }
    }

    public function confirmOrder(Order $order): Order
    {
        $order = $this->lockOrder($order);
        OrderStateMachine::assertTransition($order->status, OrderStateMachine::CONFIRMED);

        if ($order->payment_status === 'failed') {
            throw new BusinessException('The order payment failed and cannot be confirmed.');
        }

        $order = $this->orders->update($order, [
            'status' => OrderStateMachine::CONFIRMED,
            'confirmed_at' => now(),
        ]);

        $this->notifications->sendOrderNotification(
            $order->customer?->fcm_token ?? '',
            ['order_number' => $order->order_number, 'status' => 'confirmed']
        );

        return $order;
    }

    public function transitionOrder(Order $order, string $to, ?string $actor = null): Order
    {
        $order = $this->lockOrder($order);
        OrderStateMachine::assertTransition($order->status, $to);

        if (OrderStateMachine::isTerminal($to)) {
            throw new BusinessException('Cannot transition into a terminal state via updateStatus.');
        }

        // Actor-level permission on top of the legal transition.
        if (! $this->actorMay($order, $to, $actor)) {
            throw new BusinessException('This actor is not allowed to move the order to the requested status.');
        }

        return $this->orders->update($order, [
            'status' => $to,
            'confirmed_at' => $to === OrderStateMachine::CONFIRMED ? now() : $order->confirmed_at,
            'preparing_at' => $to === OrderStateMachine::PREPARING ? now() : $order->preparing_at,
            'ready_at' => $to === OrderStateMachine::READY_FOR_PICKUP ? now() : $order->ready_at,
            'picked_up_at' => $to === OrderStateMachine::OUT_FOR_DELIVERY ? now() : $order->picked_up_at,
        ]);
    }

    public function cancelOrder(Order $order, string $reason = null, ?string $actor = null): Order
    {
        return DB::transaction(function () use ($order, $reason, $actor) {
            $locked = $this->lockOrder($order);

            if (! OrderStateMachine::isCancellable($locked->status)) {
                throw new BusinessException(
                    "An order in '{$locked->status}' state cannot be cancelled."
                );
            }

            $updated = $this->orders->update($locked, [
                'status' => OrderStateMachine::CANCELLED,
                'cancellation_reason' => $reason ?? $locked->cancellation_reason,
                'cancelled_at' => now(),
            ]);

            // Restore stock exactly once (only when leaving a non-cancelled
            // cancellable state). The state machine guard + lock make repeat
            // cancellation impossible, so stock is never double-restored.
            foreach ($updated->items as $item) {
                $product = $this->lockProduct($item->product_id);
                $this->products->update($product, [
                    'stock_quantity' => $product->stock_quantity + $item->quantity,
                ]);
            }

            return $updated;
        });
    }

    public function markDelivered(Order $order): Order
    {
        $order = $this->lockOrder($order);
        OrderStateMachine::assertTransition($order->status, OrderStateMachine::DELIVERED);

        if (! $this->isPaymentSettled($order)) {
            throw new BusinessException('Order cannot be delivered before the payment is settled.');
        }

        return $this->orders->update($order, [
            'status' => OrderStateMachine::DELIVERED,
            'delivered_at' => now(),
        ]);
    }

    public function assignDriver(Order $order, int $driverId): Order
    {
        return DB::transaction(function () use ($order, $driverId) {
            $locked = $this->lockOrder($order);

            if ($locked->status !== OrderStateMachine::CONFIRMED) {
                throw new BusinessException('Order is not available for delivery assignment.');
            }

            if ($locked->driver_id !== null) {
                // Concurrent/exact-dup claim: fail deterministically.
                throw new BusinessException('An order can only be claimed by one driver.');
            }

            $driver = $this->drivers->findById($driverId);
            if ($driver === null || ! $driver->isApproved() || ! $driver->is_online || ! $driver->is_available) {
                throw new BusinessException('The driver is not currently available.');
            }

            $updated = $this->orders->update($locked, ['driver_id' => $driverId]);

            // Unique order_id index on deliveries makes a duplicate record
            // impossible; the status guard above already prevented re-claim.
            $this->deliveries->createForOrder($updated, $driverId);

            return $updated->load('items');
        });
    }

    public function updateDeliveryStatus(Delivery $delivery, string $status, array $data = [], ?Driver $driver = null): Delivery
    {
        return DB::transaction(function () use ($delivery, $status, $data, $driver) {
            $locked = Delivery::whereKey($delivery->id)->lockForUpdate()->first();
            if ($locked === null) {
                throw new BusinessException('Delivery not found.');
            }

            DeliveryStateMachine::assertTransition($locked->status, $status);

            if ($driver !== null && $locked->driver_id !== $driver->id) {
                throw new BusinessException('This driver does not own the delivery.');
            }

            $updated = $this->deliveries->updateStatus($locked, $status, $data);

            if ($status === DeliveryStateMachine::DELIVERED) {
                // Idempotent: delivery state machine is terminal, so the order
                // is marked delivered (and earnings credited) exactly once.
                $this->markDelivered($updated->order);
                $this->creditDriverEarnings($updated);
            }

            return $updated;
        });
    }

    public function calculateTotals(array $items, array $deliveryData = []): array
    {
        $commissionRate = (float) config('app_settings.business.commission_rate', 15);

        $subtotal = array_sum(array_map(fn ($item) => $item['total_amount'] ?? $item['total'], $items));
        $deliveryFee = $this->calculateDeliveryFee($deliveryData);
        $tax = round($subtotal * 0.05, 2);
        $discount = $deliveryData['discount'] ?? 0;
        $total = round($subtotal + $deliveryFee + $tax - $discount, 2);
        $commission = round($subtotal * $commissionRate / 100, 2);
        $vendorAmount = round($subtotal - $commission, 2);

        return [
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'tax' => $tax,
            'discount' => $discount,
            'total' => $total,
            'commission' => $commission,
            'vendor_amount' => $vendorAmount,
            'commission_rate' => $commissionRate,
        ];
    }

    public function getStatusHistory(Order $order): array
    {
        return collect([
            ['status' => OrderStateMachine::PENDING, 'at' => $order->created_at],
            ['status' => OrderStateMachine::CONFIRMED, 'at' => $order->confirmed_at],
            ['status' => OrderStateMachine::PREPARING, 'at' => $order->preparing_at],
            ['status' => OrderStateMachine::READY_FOR_PICKUP, 'at' => $order->ready_at],
            ['status' => OrderStateMachine::DELIVERED, 'at' => $order->delivered_at],
        ])->reject(fn ($entry) => $entry['at'] === null)
            ->map(fn ($entry) => ['status' => $entry['status'], 'at' => $entry['at']->toIso8601String()])
            ->values()
            ->all();
    }

    private function isIdempotencyConflict(\Throwable $e): bool
    {
        return $e instanceof QueryException
            && str_contains(strtolower($e->getMessage()), 'idempotency')
            && (str_contains(strtolower($e->getMessage()), 'unique') || str_contains(strtolower($e->getMessage()), 'duplicate'));
    }

    private function lockOrder(Order $order): Order
    {
        $locked = Order::whereKey($order->id)->with(['items', 'customer', 'branch'])->lockForUpdate()->first();
        if ($locked === null) {
            throw new BusinessException('Order not found.');
        }

        return $locked;
    }

    private function lockProduct(int $productId): Product
    {
        $product = Product::whereKey($productId)->lockForUpdate()->first();
        if ($product === null) {
            throw new BusinessException('Product not found.');
        }

        return $product;
    }

    private function decrementStockSafely(int $productId, int $quantity): void
    {
        $product = $this->lockProduct($productId);
        if ((int) $product->stock_quantity < $quantity) {
            throw new BusinessException("Insufficient stock for '{$product->name}'.");
        }
        $this->products->decrementStock($product, $quantity);
    }

    private function isPaymentSettled(Order $order): bool
    {
        if ($order->payment_status === 'completed') {
            return true;
        }
        // Cash-on-delivery / cash at pickup is settled at hand-over.
        return in_array(strtolower((string) $order->payment_method), ['cash', 'cod', 'cash_on_delivery'], true);
    }

    private function actorMay(Order $order, string $to, ?string $actor): bool
    {
        // Vendor drives the fulfilment chain (confirmed/preparing/ready).
        if (in_array($to, [OrderStateMachine::CONFIRMED, OrderStateMachine::PREPARING, OrderStateMachine::READY_FOR_PICKUP], true)) {
            return $actor === null || $actor === 'vendor';
        }
        // Driver handles hand-off (out_for_delivery).
        if ($to === OrderStateMachine::OUT_FOR_DELIVERY) {
            return $actor === 'driver';
        }

        return true;
    }

    private function creditDriverEarnings(Delivery $delivery): void
    {
        $driver = $this->drivers->findById($delivery->driver_id);
        if ($driver === null) {
            return;
        }

        $this->drivers->update($driver, [
            'total_deliveries' => ((int) $driver->total_deliveries) + 1,
            'completed_deliveries' => ((int) $driver->completed_deliveries) + 1,
            'available_balance' => $driver->available_balance + ($delivery->driver_earning ?? 0),
            'total_earnings' => $driver->total_earnings + ($delivery->driver_earning ?? 0),
        ]);
    }

    private function calculateDeliveryFee(array $deliveryData): float
    {
        $type = config('app_settings.business.delivery_fee_type', 'distance');
        $base = (float) config('app_settings.business.base_delivery_fee', 5);
        $perKm = (float) config('app_settings.business.per_km_rate', 0.5);

        if ($type === 'fixed') {
            return $base;
        }

        return round($base + (((float) ($deliveryData['distance_km'] ?? 0)) * $perKm), 2);
    }

    private function generateOrderNumber(): string
    {
        return 'ORD-'.strtoupper(Str::orderedUuid()->toString());
    }
}
