<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Administrator - Lada Bits</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            background-color: #f8f9fa; /* Warna putih/abu terang */
            font-family: 'Segoe UI', sans-serif;
        }
        .login-card {
            border: none;
            box-shadow: 0 15px 35px rgba(209, 0, 0, 0.2);
            border-radius: 16px;
            background-color: #D80309; /* Kontainer form warna merah */
            color: #fff;
        }
        .form-control {
            background-color: #ffffff;
            border: none;
            color: #333;
        }
        .form-control:focus {
            background-color: #ffffff;
            color: #333;
            box-shadow: 0 0 0 0.25rem rgba(255, 255, 255, 0.5);
        }
        .input-group-text {
            background-color: #ffffff;
            border: none;
            color: #D80309;
        }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center min-vh-screen" style="min-height: 100vh;">

<div class="container">
    <div class="row justify-content-center w-100">
        <div class="col-md-4">
            <div class="card login-card p-4">
                <div class="text-center mb-4">
                    <div class="bg-white rounded-circle p-2 d-inline-block mb-3" style="width: 70px; height: 70px; overflow: hidden;">
                        <img src="{{ asset('images/logo.png') }}" alt="Logo" style="width: 100%; height: 100%; object-fit: contain;">
                    </div>
                    <h4 class="fw-bold mb-1">Lada Bits Admin</h4>
                    <small class="text-white-50">Masuk sebagai Administrator / Owner</small>
                </div>

                <div id="alertContainer"></div>

                <form id="adminLoginForm">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-uppercase text-white-50">Email Admin</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-regular fa-envelope"></i></span>
                            <input type="email" id="email" class="form-control" placeholder="admin@ladabits.com" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-uppercase text-white-50">Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                            <input type="password" id="password" class="form-control" placeholder="••••••••" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-light w-100 rounded-pill py-2 fw-bold text-uppercase mt-3">Masuk Panel</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // HUBUNGKAN FORM KE API BACKEND LARAVEL
    document.getElementById('adminLoginForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;
        const alertContainer = document.getElementById('alertContainer');

        try {
            const response = await fetch('/api/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ email, password })
            });

            const result = await response.json();

            if (response.ok) {
                // VALIDASI OTORISASI: Pastikan yang login memiliki role 'admin'
                if (result.data.role !== 'admin') {
                    alertContainer.innerHTML = `<div class="alert alert-danger border-0 small py-2 rounded-3">Akses ditolak. Akun Anda bukan Administrator.</div>`;
                    return;
                }

                // Jika sukses, simpan kredensial ke localStorage browser
                localStorage.setItem('auth_token', result.access_token);
                localStorage.setItem('user_role', result.data.role);
                localStorage.setItem('user_name', result.data.name);

                // Simpan token ke cookie agar server bisa memvalidasi halaman web admin
                document.cookie = `admin_token=${result.access_token}; path=/; max-age=86400`; // Berlaku 1 hari

                // Lempar ke Dashboard Admin
                window.location.href = '/admin/dashboard';
            } else {
                alertContainer.innerHTML = `<div class="alert alert-danger border-0 small py-2 rounded-3">${result.message}</div>`;
            }
        } catch (error) {
            alertContainer.innerHTML = `<div class="alert alert-danger border-0 small py-2 rounded-3">Gagal berkomunikasi dengan API Server.</div>`;
        }
    });
</script>
</body>
</html>