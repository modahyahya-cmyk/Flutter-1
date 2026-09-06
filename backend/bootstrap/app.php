<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

/*
|--------------------------------------------------------------------------
| Laravel 11 Core Routing & Middleware Configuration Alignment
|--------------------------------------------------------------------------
*/
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php', // تم ربط وضمان مسارات الـ API لتطبيقات الـ Mobile هنا
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // حقن معالجات الأمان المدعومة لبيئة التوصيل والإنتاج
        $middleware->validateCsrfTokens(except: [
            'api/v1/*', // استثناء مسارات التطبيقات من حظر الـ CSRF لضمان استقبال الـ Payloads
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // معالجة الأخطاء الافتراضية
    })->create();