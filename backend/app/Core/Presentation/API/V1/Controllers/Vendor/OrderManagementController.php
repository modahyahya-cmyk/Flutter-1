<?php

namespace App\Core\Presentation\API\V1\Controllers\Vendor;

use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Repositories\VendorRepositoryInterface;
use App\Core\Domain\Services\OrderServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\OrderResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderManagementController extends BaseController
{
    public function __construct(
        private OrderRepositoryInterface $orders,
        private OrderServiceInterface $orderService,
        private VendorRepositoryInterface $vendors,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            OrderResource::collection($this->orders->paginateForVendor($vendor->id, min($perPage, 100)))
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $vendor = $this->vendorFrom($request);
        $order = $this->orders->findById($id);

        abort_if($order === null || $order->vendor_id !== $vendor->id, 404, 'Order not found.');

        return $this->success(OrderResource::make($order));
    }

    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:confirmed,preparing,ready_for_pickup,cancelled'],
        ]);

        $vendor = $this->vendorFrom($request);
        $order = $this->orders->findById($id);

        abort_if($order === null || $order->vendor_id !== $vendor->id, 404, 'Order not found.');

        if ($validated['status'] === 'cancelled') {
            // Verified against the order state machine (only pending/confirmed
            // may be cancelled, and stock is restored exactly once).
            $order = $this->orderService->cancelOrder($order, $request->input('reason'), 'vendor');
        } else {
            // Authoritative transition through the order state machine.
            $order = $this->orderService->transitionOrder($order, $validated['status'], 'vendor');
        }

        return $this->success(OrderResource::make($order), 'Order status updated.');
    }

    private function vendorFrom(Request $request)
    {
        $user = $request->attributes->get('user');
        $vendor = $this->vendors->findByUserId($user->id);

        abort_if($vendor === null, 403, 'No vendor profile linked to this account.');

        return $vendor;
    }
}
