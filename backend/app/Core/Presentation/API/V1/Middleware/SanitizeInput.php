<?php

namespace App\Core\Presentation\API\V1\Middleware;

use Closure;
use Illuminate\Http\Request;

class SanitizeInput
{
    private array $stripTagsKeys = [
        'name', 'first_name', 'last_name', 'business_name', 'store_name', 'title',
        'description', 'comment', 'notes', 'reason', 'keyword', 'search',
    ];

    public function handle(Request $request, Closure $next)
    {
        $request->merge($this->sanitize($request->all()));

        return $next($request);
    }

    private function sanitize(array $input): array
    {
        foreach ($input as $key => $value) {
            if (is_array($value)) {
                $input[$key] = $this->sanitize($value);
            } elseif (is_string($value)) {
                $input[$key] = $this->cleanValue($value, $key);
            }
        }

        return $input;
    }

    private function cleanValue(string $value, string $key): string
    {
        $value = str_replace("\0", '', $value);

        if (in_array($key, $this->stripTagsKeys, true)) {
            $value = strip_tags($value);

            return trim($value);
        }

        // Trim control characters from URLs / free text
        return preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', '', $value);
    }
}
