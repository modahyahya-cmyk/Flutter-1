<?php

namespace App\Exceptions;

use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException as LaravelValidationException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    protected $dontReport = [
        BusinessException::class,
        UnauthorizedException::class,
    ];

    public function render($request, Throwable $e)
    {
        if ($request->expectsJson() || $request->is('api/*')) {
            return $this->renderApi($request, $e);
        }

        return parent::render($request, $e);
    }

    private function renderApi(Request $request, Throwable $e): JsonResponse
    {
        if ($e instanceof BusinessException) {
            return response()->json($e->toArray(), $e->getCode() ?: 422);
        }

        if ($e instanceof UnauthorizedException) {
            return response()->json($e->toArray(), $e->getCode() ?: 401);
        }

        if ($e instanceof ValidationException) {
            return response()->json($e->toArray(), 422);
        }

        if ($e instanceof LaravelValidationException) {
            return response()->json([
                'success' => false,
                'message' => 'The given data was invalid.',
                'error_code' => 'VALIDATION_ERROR',
                'errors' => $e->errors(),
            ], 422);
        }

        if ($e instanceof ModelNotFoundException) {
            return response()->json([
                'success' => false,
                'message' => 'The requested resource was not found.',
                'error_code' => 'NOT_FOUND',
            ], 404);
        }

        if ($e instanceof HttpException) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage() ?: 'Request failed.',
                'error_code' => 'HTTP_'.$e->getStatusCode(),
            ], $e->getStatusCode());
        }

        if ($e instanceof NotFoundHttpException || $e instanceof AuthenticationException) {
            $status = $e instanceof AuthenticationException ? 401 : 404;
            $message = $e instanceof AuthenticationException ? 'Unauthenticated.' : 'Endpoint not found.';

            return response()->json([
                'success' => false,
                'message' => $message,
                'error_code' => $status === 401 ? 'UNAUTHENTICATED' : 'NOT_FOUND',
            ], $status);
        }

        if (! config('app.debug')) {
            report($e);

            return response()->json([
                'success' => false,
                'message' => 'An unexpected server error occurred.',
                'error_code' => 'SERVER_ERROR',
            ], 500);
        }

        return parent::render($request, $e);
    }
}
