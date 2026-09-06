<?php

namespace App\Exceptions;

use Exception;

class BusinessException extends Exception
{
    public function __construct(
        string $message,
        int $code = 422,
        public readonly ?string $field = null,
        public readonly array $details = []
    ) {
        parent::__construct($message, $code);
    }

    public function toArray(): array
    {
        return [
            'success' => false,
            'message' => $this->getMessage(),
            'error_code' => 'BUSINESS_ERROR',
            'field' => $this->field,
            'details' => $this->details,
        ];
    }
}
