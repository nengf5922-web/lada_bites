<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') - Admin Lada Bits</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
        }
        /* Sidebar Styling (Sesuai Mockup) */
        .sidebar {
            min-width: 250px;
            max-width: 250px;
            background-color: #D80309; /* Warna merah sesuai Flutter */
            border-right: none;
            min-height: 100vh;
            color: #fff;
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            z-index: 1000;
            overflow-y: auto; /* Memungkinkan sidebar untuk discroll */
        }
        
        /* Mengubah tampilan scrollbar sidebar agar lebih rapi */
        .sidebar::-webkit-scrollbar {
            width: 6px;
        }
        .sidebar::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.3);
            border-radius: 10px;
        }
        .sidebar::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.5);
        }
        .sidebar .nav-link {
            color: rgba(255, 255, 255, 0.8);
            padding: 12px 20px;
            font-weight: 500;
            margin-bottom: 5px;
        }
        .sidebar .nav-link:hover, .sidebar .nav-link.active {
            color: #D80309;
            background-color: #ffffff;
            background-image: none;
            border-radius: 5px;
        }
        .main-content {
            margin-left: 250px;
            padding: 30px;
            width: calc(100% - 250px);
            min-height: 100vh;
        }
    </style>
    @stack('styles')
</head>
<body>

    <script>
        const token = localStorage.getItem('auth_token');
        const role = localStorage.getItem('user_role');
        
        if (!token || role !== 'admin') {
            window.location.href = '/admin/login';
        }
    </script>

    <div class="sidebar p-3 d-flex flex-column">
        <div class="d-flex align-items-center mb-4 px-2 mt-2">
            <div class="bg-white rounded-circle p-1 me-3 d-flex justify-content-center align-items-center" style="width: 45px; height: 45px; overflow: hidden;">
                <img src="{{ asset('images/logo.png') }}" alt="Logo" style="width: 100%; height: 100%; object-fit: contain;">
            </div>
            <div>
                <h6 class="mb-0 fw-bold text-white" id="topAdminName">Admin Lada Bits</h6>
                <small class="text-uppercase text-white-50" style="font-size: 10px; letter-spacing: 1px;">Administrator</small>
            </div>
        </div>
        
        <p class="text-uppercase mb-1 mt-3 px-2" style="font-size: 11px; letter-spacing: 1px; color: rgba(255,255,255,0.6);">Main Menu</p>
        <ul class="nav nav-pills flex-column mb-3">
            <li class="nav-item">
                <a href="{{ url('/admin/dashboard') }}" class="nav-link {{ request()->is('admin/dashboard') ? 'active' : '' }}">Dashboard</a>
            </li>
        </ul>

        <p class="text-uppercase mb-1 mt-2 px-2" style="font-size: 11px; letter-spacing: 1px; color: rgba(255,255,255,0.6);">Manajemen Toko</p>
        <ul class="nav nav-pills flex-column mb-auto">
            <li class="nav-item">
                <a href="{{ url('/admin/kategori') }}" class="nav-link {{ request()->is('admin/kategori') ? 'active' : '' }}">Kategori</a>
            </li>
            <li class="nav-item">
                <a href="{{ url('/admin/produk') }}" class="nav-link {{ request()->is('admin/produk') ? 'active' : '' }}">Produk</a>
            </li>
            <li class="nav-item">
                <a href="{{ url('/admin/pengguna') }}" class="nav-link d-flex justify-content-between align-items-center {{ request()->is('admin/pengguna') ? 'active' : '' }}">
                    <span>Pengguna</span>
                    @if(isset($newUsersCount) && $newUsersCount > 0)
                        <span class="badge bg-warning text-dark rounded-pill">{{ $newUsersCount }}</span>
                    @endif
                </a>
            </li>
            <li class="nav-item">
                <a href="{{ url('/admin/pesanan') }}" class="nav-link d-flex justify-content-between align-items-center {{ request()->is('admin/pesanan') ? 'active' : '' }}">
                    <span>Pesanan</span>
                    @if(isset($newOrdersCount) && $newOrdersCount > 0)
                        <span class="badge bg-warning text-dark rounded-pill">{{ $newOrdersCount }}</span>
                    @endif
                </a>
            </li>
            <li class="nav-item">
                <a href="{{ url('/admin/ongkir') }}" class="nav-link {{ request()->is('admin/ongkir') ? 'active' : '' }}">Pengaturan Ongkir</a>
            </li>
            <li class="nav-item">
                <a href="{{ url('/admin/ulasan') }}" class="nav-link d-flex justify-content-between align-items-center {{ request()->is('admin/ulasan') ? 'active' : '' }}">
                    <span>Ulasan</span>
                    @if(isset($newReviewsCount) && $newReviewsCount > 0)
                        <span class="badge bg-warning text-dark rounded-pill">{{ $newReviewsCount }}</span>
                    @endif
                </a>
            </li>
            <li class="nav-item">
                <a href="{{ url('/admin/banners') }}" class="nav-link {{ request()->is('admin/banners') ? 'active' : '' }}">Banners</a>
            </li>
        </ul>
        
        <hr class="border-secondary">
        
        <div class="mt-auto px-2 pb-3 d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
                 <div class="bg-white rounded-circle p-1 me-2 d-flex justify-content-center align-items-center" style="width: 30px; height: 30px;">
                    <span class="text-danger fw-bold" style="font-size:8px;">LB</span>
                </div>
                <div>
                    <h6 class="mb-0 fs-6 fw-bold text-white" id="sidebarAdminName">Admin</h6>
                    <small class="text-white-50" style="font-size:10px;">Online</small>
                </div>
            </div>
            <a href="#" onclick="executeAdminLogout(event)" class="text-white" title="Keluar Aplikasi"><i class="fa-solid fa-arrow-right-from-bracket fs-5"></i></a>
        </div>
    </div> 
    
    <div class="main-content">
        @yield('content')
    </div>

    <script>
        // Ambil nama dari sesi login
        const userName = localStorage.getItem('user_name') || 'Admin';

        // Pasang ke profil atas
        const topNameEl = document.getElementById('topAdminName');
        if (topNameEl) topNameEl.innerText = userName;

        // Pasang ke profil bawah
        const sidebarNameEl = document.getElementById('sidebarAdminName');
        if (sidebarNameEl) sidebarNameEl.innerText = userName;

        async function executeAdminLogout(e) {
            e.preventDefault();
            if (!confirm('Apakah Anda yakin ingin keluar dari Panel Admin?')) return;

            const adminToken = localStorage.getItem('auth_token');
            try {
                await fetch('/api/logout', {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${adminToken}`,
                        'Accept': 'application/json'
                    }
                });
            } catch (err) {
                console.error("Gagal koordinasi dengan server backend, menghapus sesi lokal...");
            }

            localStorage.clear();
            document.cookie = 'admin_token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 UTC;';
            window.location.href = '/admin/login';
        }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    @stack('scripts')
</body>
</html>