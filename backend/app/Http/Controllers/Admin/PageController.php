<?php

namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PageController extends Controller
{
    public function login()
    {
        return view('admin.login');
    }

    public function dashboard()
    {
        return view('admin.dashboard');
    }

    public function kategori()
    {
        return view('admin.kategori');
    }

    public function produk()
    {
        return view('admin.produk');
    }

    public function pesanan()
    {
        return view('admin.pesanan');
    }

    public function pengguna()
    {
        $users = \App\Models\User::orderBy('created_at', 'desc')->get();
        return view('admin.pengguna', compact('users'));
    }

    public function banners()
    {
        return view('admin.banner');
    }

    public function ulasan()
    {
        $reviews = \App\Models\Review::with(['user', 'product'])->orderBy('created_at', 'desc')->get();
        return view('admin.ulasan', compact('reviews'));
    }
}
