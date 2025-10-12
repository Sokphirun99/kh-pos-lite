<?php

use Illuminate\Support\Facades\Route;

// All routes here are prefixed with "/api" and use the "api" middleware group.
Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});

// Auth (Sanctum token-based)
Route::post('auth/register', [App\Http\Controllers\Api\AuthController::class, 'register'])->middleware('throttle:5,1');
Route::post('auth/login', [App\Http\Controllers\Api\AuthController::class, 'login'])->middleware('throttle:5,1');
Route::middleware('auth:sanctum')->group(function () {
    Route::get('auth/me', [App\Http\Controllers\Api\AuthController::class, 'me']);
    Route::post('auth/logout', [App\Http\Controllers\Api\AuthController::class, 'logout']);
});

// POS API resources
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('categories', App\Http\Controllers\Api\CategoryController::class);
    Route::apiResource('products', App\Http\Controllers\Api\ProductController::class);
    Route::apiResource('customers', App\Http\Controllers\Api\CustomerController::class);
    Route::apiResource('orders', App\Http\Controllers\Api\OrderController::class);
    Route::apiResource('order-items', App\Http\Controllers\Api\OrderItemController::class);
    Route::apiResource('payments', App\Http\Controllers\Api\PaymentController::class);
});
