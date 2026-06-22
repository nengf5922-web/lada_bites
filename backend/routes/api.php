<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\BannerController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// === RUTE PUBLIK ===
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/banners', [BannerController::class, 'index']); 
Route::get('/shipping-rates', [\App\Http\Controllers\ShippingRateController::class, 'index']); 

// Route khusus untuk Bypass CORS gambar di Flutter Web
Route::get('/image/{folder}/{filename}', function ($folder, $filename) {
    $path = storage_path('app/public/' . $folder . '/' . $filename);
    if (!file_exists($path)) {
        abort(404);
    }
    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS'
    ]);
});

// === RUTE TERPROTEKSI ===
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('products', ProductController::class)->only(['index', 'show']);
    
    // Rute Transaksi Pesanan
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::post('/orders/{id}/upload-bukti', [OrderController::class, 'uploadBuktiPembayaran']);
    Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus']);
    
    // Rute Laporan
    Route::get('/reports', [ReportController::class, 'index']);

    // Rute Profil
    Route::get('/user-profile', function (Request $request) {
        return $request->user();
    });

    // Rute Update Profil (Hanya 1 di sini saja!)
    Route::post('/user-profile/update', [AuthController::class, 'updateProfile']);

    // Rute Ulasan (Review)
    Route::get('/user/reviewable-products', [\App\Http\Controllers\ReviewController::class, 'getReviewableProducts']);
    Route::post('/reviews', [\App\Http\Controllers\ReviewController::class, 'store']);

    // API Kategori (Public Index, Admin Create/Delete)
    Route::get('/categories', [CategoryController::class, 'index']);

    // Rute Ulasan Produk (Public Index)
    Route::get('/products/{id}/reviews', [\App\Http\Controllers\ReviewController::class, 'getProductReviews']);

    // --- RUTE KHUSUS ADMIN ---
    Route::middleware('admin')->group(function () {
        // Produk (Create, Update, Delete)
        Route::post('/products', [ProductController::class, 'store']);
        Route::match(['put', 'patch'], '/products/{product}', [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);
        
        // Kategori (Create, Update, Delete)
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{id}', [CategoryController::class, 'update']);
        Route::delete('/categories/{id}', [CategoryController::class, 'destroy']);

        // Pengguna (Create, Read, Update, Delete)
        Route::get('/users', [\App\Http\Controllers\UserController::class, 'index']);
        Route::post('/users', [\App\Http\Controllers\UserController::class, 'store']);
        Route::put('/users/{id}', [\App\Http\Controllers\UserController::class, 'update']);
        Route::delete('/users/{id}', [\App\Http\Controllers\UserController::class, 'destroy']);

        // Manajemen Banner
        Route::get('/admin/banners', [BannerController::class, 'adminIndex']);
        Route::post('/admin/banners', [BannerController::class, 'store']);
        Route::post('/admin/banners/{id}', [BannerController::class, 'update']); // Pakai POST karena form-data
        Route::delete('/admin/banners/{id}', [BannerController::class, 'destroy']);

        // Pengaturan Ongkir
        Route::post('/shipping-rates', [\App\Http\Controllers\ShippingRateController::class, 'store']);
        Route::put('/shipping-rates/{id}', [\App\Http\Controllers\ShippingRateController::class, 'update']);
        Route::delete('/shipping-rates/{id}', [\App\Http\Controllers\ShippingRateController::class, 'destroy']);

        // Laporan (Admin Only)
        Route::get('/reports', [ReportController::class, 'index']);

        // Update Status Pesanan (Admin Only)
        Route::patch('/orders/{id}/status', [OrderController::class, 'updateStatus']);
        
        // Daftar Semua Pesanan (Admin Only)
        Route::get('/admin/orders', [OrderController::class, 'adminIndex']);
    });
});