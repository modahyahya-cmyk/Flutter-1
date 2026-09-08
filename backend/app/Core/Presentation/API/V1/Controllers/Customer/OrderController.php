<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Repositories\ProductRepositoryInterface;
use App\Core\Domain\Services\OrderServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Requests\Order\CreateOrderRequest;
use App\Core\Presentation\API\V1\Resources\OrderResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends BaseController
{
    public function __construct(
        private OrderServiceInterface $orderService,
        private OrderRepositoryInterface $orders,
        private ProductRepositoryInterface $products,
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->attributes->get('user');
        $perPage = (int) $request->query('per_page', 15);

        return $this->paginated(
            OrderResource::collection($this->orders->paginateForCustomer($user->id, min($perPage, 50)))
        );
    }

    public function store(CreateOrderRequest $request): JsonResponse
    {
        $user = $request->attributes->get('user');
        $data = $request->validated();

        $enrichedItems = $this->enrichItems($data['items']);

        if (($data['vendor_id'] ?? null) === null) {
            $data['vendor_id'] = $enrichedItems[0]['vendor_id'] ?? null;
        }

        $allSameVendor = collect($enrichedItems)->every(fn ($i) => $i['vendor_id'] === $data['vendor_id']);
        abort_unless($allSameVendor, 422, 'All cart items must come from a single vendor.');

        $data['items'] = $enrichedItems;
        $data['lat'] = $data['customer_latitude'] ?? null;
        $data['lng'] = $data['customer_longitude'] ?? null;

        $order = $this->orderService->createOrder($user, $data);

        return $this->success(OrderResource::make($order->load('customer', 'vendor', 'items')), 'Order created successfully.', 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->attributes->get('user');
        $order = $this->orders->findById($id);

        abort_if($order === null || $order->customer_id !== $user->id, 404, 'Order not found.');

        return $this->success(OrderResource::make($order));
    }

    public function cancel(Request $request, int $id): JsonResponse
    {
        $user = $request->attributes->get('user');
        $order = $this->orders->findById($id);

        abort_if($order === null || $order->customer_id !== $user->id, 404, 'Order not found.');

        $order = $this->orderService->cancelOrder($order, $request->input('reason'), 'customer');

        return $this->success(OrderResource::make($order), 'Order cancelled.');
    }

    private function enrichItems(array $items): array
    {
        return collect($items)->map(function ($item) {
            $product = $this->products->findById((int) $item['product_id']);
            abort_if($product === null, 422, 'Product not found.');

            // Only purchasable products may be ordered. Inactive/draft
            // products must not be orderable even if the id is known.
            abort_unless(
                $product->status === 'active',
                422,
                "Product '{$product->name}' is not available for purchase."
            );

            $unitPrice = $product->price;

            if (! empty($item['product_variant_id'])) {
                $variant = $product->variants->firstWhere('id', (int) $item['product_variant_id']);
                abort_if($variant === null, 422, 'Product variant not found.');
                abort_unless(
                    (bool) $variant->is_active,
                    422,
                    "Product variant '{$variant->name}' is not available."
                );
                $unitPrice = $variant->price;
            }

            return [
                'product_id' => $product->id,
                'variant_id' => $item['product_variant_id'] ?? $item['variant_id'] ?? null,
                'product_name' => $product->name,
                'variant_name' => $item['variant_name'] ?? null,
                'quantity' => (int) $item['quantity'],
                'unit_price' => $unitPrice,
                'total_amount' => round($unitPrice * (int) $item['quantity'], 2),
                'vendor_id' => $product->vendor_id,
            ];
        })->all();
    }
}
