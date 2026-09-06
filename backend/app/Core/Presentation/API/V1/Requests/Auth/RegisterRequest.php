<?php

namespace App\Core\Presentation\API\V1\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $min = (int) config('app_settings.security.password_min_length', 8);

        return [
            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:20', 'unique:users,phone'],
            'password' => ['required', 'string', "min:{$min}"],
            'role' => ['nullable', 'in:customer,vendor,driver'],
            'device_token' => ['nullable', 'string', 'max:255'],
            // Vendor profile fields (optional; a pending profile is created
            // when absent and operational access is gated by admin approval).
            'business_name' => ['nullable', 'string', 'max:255'],
            'business_email' => ['nullable', 'email', 'max:255'],
            'business_phone' => ['nullable', 'string', 'max:20'],
            // Driver profile fields.
            'vehicle_type' => ['nullable', 'string', 'max:50'],
            'vehicle_plate' => ['nullable', 'string', 'max:20'],
            'license_number' => ['nullable', 'string', 'max:50'],
        ];
    }
}
