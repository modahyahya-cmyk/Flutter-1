<?php

namespace App\Exceptions;

use Exception;

class ValidationException extends Exception
{
    public function __construct(private array $errors)
    {
        parent::__construct('The given data was invalid.', 422);
    }

    public function errors(): array
    {
        return $this->errors;
    }

    public function toArray(): array
    {
        return [
            'success' => false,
            'message' => $this->getMessage(),
            'error_code' => 'VALIDATION_ERROR',
            'errors' => $this->errors,
        ];
    }
}
