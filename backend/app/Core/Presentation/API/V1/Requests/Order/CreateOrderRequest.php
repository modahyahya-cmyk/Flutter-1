<?php

namespace App\Core\Presentation\API\V1\Requests\Order;

use Illuminate\Foundation\Http\FormRequest;

class CreateOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'idempotency_key' => ['nullable', 'string', 'max:100'],
            'vendor_id' => ['required', 'exists:vendors,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.product_variant_id' => ['nullable', 'exists:product_variants,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'address_id' => ['nullable', 'exists:addresses,id'],
            'fulfillment_type' => ['nullable', 'in:delivery,pickup'],
            // 'wallet' is intentionally absent: no wallet gateway is
            // implemented, so accepting it would create orders that can
            // never be paid.
            'payment_method' => ['nullable', 'in:stripe,paystack,razorpay,paypal,cash_on_delivery'],
            // Must match the orders.customer_notes column and the key read
            // by OrderProcessingService::createOrder().
            'customer_notes' => ['nullable', 'string', 'max:1000'],
            'delivery_address' => ['nullable', 'string', 'max:500'],
            'customer_latitude' => ['nullable', 'numeric', 'between:-90,90'],
            'customer_longitude' => ['nullable', 'numeric', 'between:-180,180'],
        ];
    }
}
