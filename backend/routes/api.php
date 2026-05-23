<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\AnalyticsController;
use App\Http\Controllers\Api\SubscriptionController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::prefix('v1')->group(function () {
    // Store public routes
    Route::get('/stores', [StoreController::class, 'index']);
    Route::get('/stores/search-by-phone', [StoreController::class, 'findByPhone']);
    Route::get('/stores/{identifier}', [StoreController::class, 'show']);
    
    // Plans
    Route::get('/plans', [SubscriptionController::class, 'plans']);
    
    Route::get('/debug/cleanup-db', function() {
        \DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        \DB::table('products')->truncate();
        \DB::table('orders')->truncate();
        \DB::table('customers')->truncate();
        \DB::table('stores')->truncate();
        \DB::statement('SET FOREIGN_KEY_CHECKS=1;');
        return "Database cleaned successfully";
    });
    Route::get('/stores/{storeSlug}/products', [ProductController::class, 'byStore']);
    
    // Analytics tracking (public)
    Route::post('/analytics/track', [AnalyticsController::class, 'track']);
});

// Seller app routes (no auth required for MVP)
Route::prefix('v1/seller')->group(function () {
    Route::post('/stores/{store}/update', [StoreController::class, 'update']);
    Route::apiResource('stores', StoreController::class);
    Route::get('/stores/{store}/statistics', [StoreController::class, 'statistics']);
    Route::post('/products/{product}/update', [ProductController::class, 'update']);
    Route::apiResource('products', ProductController::class);
    Route::get('/stores/{storeId}/products', [ProductController::class, 'index']);
    
    // Subscriptions
    Route::post('/subscriptions', [SubscriptionController::class, 'store']);
    Route::post('/payments/verify', [SubscriptionController::class, 'verifyPayment']);
});

// Admin routes (protected)
Route::prefix('v1/admin')->group(function () {
    // Auth routes
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    
    Route::middleware('auth:admin')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::get('/me', [AuthController::class, 'me']);
        
        // Admin store management
        Route::get('/stores', [StoreController::class, 'index']);
        Route::get('/stores/{store}', [StoreController::class, 'show']);
        Route::put('/stores/{store}', [StoreController::class, 'update']);
        Route::delete('/stores/{store}', [StoreController::class, 'destroy']);
        
        // Admin product management
        Route::get('/products', [ProductController::class, 'index']);
        Route::get('/products/{product}', [ProductController::class, 'show']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);
        
        // Analytics
        Route::get('/analytics/global', [AnalyticsController::class, 'globalAnalytics']);
        Route::get('/analytics/stores/{storeId}', [AnalyticsController::class, 'storeAnalytics']);
    });
});

// Health check
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'LinkKart API is running',
        'version' => '1.0.0',
        'timestamp' => now()->toIso8601String(),
    ]);
});
