<?php

namespace App\Core\Presentation\API\V1\Requests\Subscription;

use Illuminate\Foundation\Http\FormRequest;

class CreateSubscriptionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'plan_code' => ['required', 'string', 'exists:subscription_plans,code'],
            'provider' => ['nullable', 'in:stripe,paystack,razorpay,paypal,manual'],
            'external_reference' => ['nullable', 'string', 'max:255'],
        ];
    }
}
