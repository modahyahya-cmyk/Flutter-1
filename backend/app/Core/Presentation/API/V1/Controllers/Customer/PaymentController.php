<?php

namespace App\Core\Presentation\API\V1\Controllers\Customer;

use App\Core\Domain\Repositories\OrderRepositoryInterface;
use App\Core\Domain\Services\PaymentServiceInterface;
use App\Core\Presentation\API\V1\Controllers\BaseController;
use App\Core\Presentation\API\V1\Resources\PaymentResource;
use App\Exceptions\BusinessException;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends BaseController
{
    public function __construct(
        private PaymentServiceInterface $payments,
        private OrderRepositoryInterface $orders,
    ) {
    }

    /**
     * Start a payment for one of the authenticated customer's orders.
     * Returns a provider checkout reference/URL; the client must NOT be trusted
     * to mark anything paid — the server verifies via the verify endpoint or
     * webhook.
     */
    public function initialize(Request $request): JsonResponse
    {
        $user = $request->attributes->get('user');
        $data = $request->validate([
            'order_id' => ['required', 'integer', 'exists:orders,id'],
            'provider' => ['required', 'string', 'in:stripe,paystack,razorpay,cash_on_delivery'],
        ]);

        $order = $this->orders->findById((int) $data['order_id']);
        abort_if($order === null || $order->customer_id !== $user->id, 404, 'Order not found.');

        if ($order->payment_status === 'completed') {
            throw new BusinessException('This order is already paid.');
        }

        if ($order->payment_status === 'failed') {
            throw new BusinessException('This order payment has failed; create a new order to retry.');
        }

        $provider = $data['provider'];
        if ($provider === 'cash_on_delivery') {
            // COD requires no gateway init; mark the order for on-delivery settlement.
            $order->update(['payment_method' => 'cash_on_delivery']);

            return $this->success([
                'provider' => 'cash_on_delivery',
                'status' => 'pending',
                'order_id' => $order->id,
            ], 'Cash on delivery enabled for this order.');
        }

        $result = $this->payments->initializePayment($order, $provider, $user);

        return $this->success(array_merge($result, ['order_id' => $order->id]), 'Payment initialized.', 201);
    }

    /**
     * Server-side verification of a payment reference. The order is only
     * marked paid when the provider confirms it — never from client state.
     */
    public function show(Request $request, string $reference): JsonResponse
    {
        $user = $request->attributes->get('user');
        $payment = Payment::where('payment_reference', $reference)->first();

        abort_if($payment === null || $payment->user_id !== $user->id, 404, 'Payment not found.');

        $verified = $this->payments->verifyPayment($reference);

        $payment->refresh();

        return $this->success([
            'payment' => PaymentResource::make($payment),
            'verified' => $verified['success'] ?? false,
        ], $verified['success'] ? 'Payment verified.' : 'Payment not yet completed.');
    }

    /**
     * Refund an order's completed payment (admin only).
     */
    public function refund(Request $request, Payment $payment): JsonResponse
    {
        $data = $request->validate([
            'amount' => ['nullable', 'numeric', 'min:0.01'],
        ]);

        $result = $this->payments->refund($payment->order, isset($data['amount']) ? (float) $data['amount'] : null);

        return $this->success($result, 'Refund processed.');
    }
}
