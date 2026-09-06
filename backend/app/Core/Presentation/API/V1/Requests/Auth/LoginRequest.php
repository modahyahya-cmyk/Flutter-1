<?php

namespace App\Core\Presentation\API\V1\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string', 'max:255'],
            'guard' => ['nullable', 'in:customer,vendor,driver,admin,any'],
            'device_token' => ['nullable', 'string', 'max:255'],
        ];
    }
}
