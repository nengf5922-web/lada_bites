<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Admin\PageController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return redirect('/admin/login');
});

// Bypass CORS untuk gambar di Flutter Web saat development
Route::get('/storage/products/{filename}', function ($filename) {
    $path = storage_path('app/public/products/' . $filename);
    if (!file_exists($path)) {
        abort(404);
    }
    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*'
    ]);
});

// Rute Tampilan Admin
Route::get('/admin/login', [PageController::class, 'login'])->name('admin.login');

Route::middleware('web.admin')->group(function () {
    Route::get('/admin/dashboard', [PageController::class, 'dashboard']);
    Route::get('/admin/reports/download', [\App\Http\Controllers\ReportController::class, 'downloadCsv'])->name('admin.reports.download');
    Route::get('/admin/kategori', [PageController::class, 'kategori']);
    Route::get('/admin/produk', [PageController::class, 'produk']);
    Route::get('/admin/pesanan', [PageController::class, 'pesanan']);
    Route::get('/admin/pengguna', [PageController::class, 'pengguna']);
    Route::get('/admin/banners', [PageController::class, 'banners']);
    Route::get('/admin/ulasan', [PageController::class, 'ulasan']);
    Route::get('/admin/ongkir', [\App\Http\Controllers\ShippingRateController::class, 'adminIndex']);
});