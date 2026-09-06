<?php

namespace App\Core\Presentation\API\V1\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class ResetPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $min = (int) config('app_settings.security.password_min_length', 8);

        return [
            'token' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string', "min:{$min}", 'confirmed'],
        ];
    }
}
