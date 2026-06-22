@extends('layouts.admin')

@section('title', 'Daftar Pengguna')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h3 class="fw-bold mb-0">Daftar Pengguna</h3>
        <small class="text-muted">Lihat akun pelanggan dan admin Lada Bits</small>
    </div>
</div>

<div class="card border-0 shadow-sm rounded-4 p-4" style="background-color: #E9ECEF;">
    <div id="alertContainer"></div>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-uppercase" style="font-size: 12px; letter-spacing: 0.5px;">
                <tr>
                    <th>User</th>
                    <th>Bergabung</th>
                    <th>Email</th>
                </tr>
            </thead>
            <tbody id="penggunaTableBody">
                <tr>
                    <td colspan="3" class="text-center text-muted py-3">Memuat data pengguna...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

@push('scripts')
<script>
    const apiToken = localStorage.getItem('auth_token');
    const tableBody = document.getElementById('penggunaTableBody');
    const alertContainer = document.getElementById('alertContainer');

    function formatDate(dateString) {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(dateString).toLocaleDateString('id-ID', options);
    }

    // 1. READ: Menampilkan Data Pengguna
    async function loadUsers() {
        try {
            const response = await fetch('/api/users', {
                headers: {
                    'Authorization': `Bearer ${apiToken}`,
                    'Accept': 'application/json'
                }
            });
            const result = await response.json();

            if (response.ok) {
                let html = '';
                if (result.data.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-muted py-3">Belum ada pengguna.</td></tr>`;
                    return;
                }

                result.data.forEach(user => {
                    const badgeClass = user.role === 'admin' ? 'danger' : 'primary';
                    html += `
                    <tr>
                        <td>
                            <div class="d-flex align-items-center">
                                <div class="rounded-circle me-3 border d-flex justify-content-center align-items-center bg-light text-muted" style="width: 40px; height: 40px;">
                                    <i class="fa-solid fa-user"></i>
                                </div>
                                <div>
                                    <div class="fw-bold">${user.name}</div>
                                    <span class="badge bg-${badgeClass} rounded-pill" style="font-size: 10px;">${user.role}</span>
                                </div>
                            </div>
                        </td>
                        <td>${formatDate(user.created_at)}</td>
                        <td>${user.email}</td>
                    </tr>`;
                });
                tableBody.innerHTML = html;
            } else {
                tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger py-3">Gagal mengambil data.</td></tr>`;
            }
        } catch (error) {
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger py-3">Kesalahan jaringan.</td></tr>`;
        }
    }

    loadUsers();
</script>
@endpush
@endsection