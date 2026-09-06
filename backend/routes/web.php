<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn () => response()->json([
    'service' => config('app_settings.app_name', 'VendorHub'),
    'status' => 'running',
    'docs' => '/api/documentation',
]));
