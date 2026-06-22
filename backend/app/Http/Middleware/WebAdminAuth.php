<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

use Laravel\Sanctum\PersonalAccessToken;

class WebAdminAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->cookie('admin_token');

        if (!$token) {
            return redirect('/admin/login');
        }

        $accessToken = PersonalAccessToken::findToken($token);

        if (!$accessToken || !$accessToken->tokenable || $accessToken->tokenable->role !== 'admin') {
            return redirect('/admin/login');
        }

        return $next($request);
    }
}
