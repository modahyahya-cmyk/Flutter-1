<?php

namespace App\Models\Concerns;

use Illuminate\Support\Str;

/**
 * Generates a UUID for the `uuid` column on model creation.
 * Apply with `use HasUuid;` on any model whose table has a `uuid` column.
 */
trait HasUuid
{
    protected static function bootHasUuid(): void
    {
        static::creating(function ($model) {
            if (empty($model->uuid)) {
                $model->uuid = (string) Str::uuid();
            }
        });
    }
}
