<?php

namespace App\Core\Presentation\API\V1\Controllers\Driver;

use App\Core\Domain\Repositories\DeliveryRepositoryInterface;
use App\Core\Domain\Repositories\DriverRepositoryInterface;
use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Services\OrderServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\DeliveryResource;
use App\Core\Presentation\API\V1\Resources\OrderResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeliveryController extends BaseController
{
    public function __construct(
        private DeliveryRepositoryInterface $deliveries,
        private DriverRepositoryInterface $drivers,
        private OrderRepositoryInterface $orders,
        private OrderServiceInterface $orderService,
    ) {
    }

    public function available(Request $request): JsonResponse
    {
        return $this->success(OrderResource::collection(
            $this->orders->findPendingForDriverAssignment((int) $request->query('limit', 10))
        ));
    }

    public function mine(Request $request): JsonResponse
    {
        $driver = $this->driverFrom($request);
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            DeliveryResource::collection($this->deliveries->paginateForDriver($driver->id, min($perPage, 50)))
        );
    }

    public function accept(Request $request, int $orderId): JsonResponse
    {
        $driver = $this->driverFrom($request);
        $order = $this->orders->findById($orderId);

        abort_if($order === null, 404, 'Order not found.');

        // Atomic, race-safe claim. assignDriver also creates the Delivery
        // record (guarded by a unique order_id index), so no duplicate is
        // created here and exactly one concurrent claim succeeds.
        $order = $this->orderService->assignDriver($order, $driver->id);

        return $this->success(OrderResource::make($order), 'Delivery accepted.');
    }

    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:picked_up,in_transit,delivered,failed,cancelled'],
            'latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $driver = $this->driverFrom($request);
        $delivery = $this->deliveries->findById($id);

        abort_if($delivery === null || $delivery->driver_id !== $driver->id, 404, 'Delivery not found.');

        // All delivery transitions are validated by the DELIVERY state machine
        // inside the service (legal transition + ownership + idempotent
        // completion + earnings crediting).
        $delivery = $this->orderService->updateDeliveryStatus($delivery, $validated['status'], $validated, $driver);

        return $this->success(DeliveryResource::make($delivery), 'Delivery status updated.');
    }

    private function driverFrom(Request $request)
    {
        $user = $request->attributes->get('user');
        $driver = $this->drivers->findByUserId($user->id);

        abort_if($driver === null, 403, 'No driver profile linked to this account.');

        return $driver;
    }
}
