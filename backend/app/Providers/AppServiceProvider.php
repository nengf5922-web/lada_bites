<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \Illuminate\Support\Facades\View::composer('layouts.admin', function ($view) {
            $newOrdersCount = \App\Models\Order::whereIn('status', ['pending', 'menunggu pembayaran', 'menunggu konfirmasi'])->count();
            $newUsersCount = \App\Models\User::whereDate('created_at', \Carbon\Carbon::today())->count();
            $newReviewsCount = \App\Models\Review::whereDate('created_at', \Carbon\Carbon::today())->count();

            $view->with(compact('newOrdersCount', 'newUsersCount', 'newReviewsCount'));
        });
    }
}
