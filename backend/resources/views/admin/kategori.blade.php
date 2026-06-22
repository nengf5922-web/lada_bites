@extends('layouts.admin')

@section('title', 'Manajemen Kategori')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h3 class="fw-bold mb-0">Daftar Kategori</h3>
        <small class="text-muted">Kelola kategori produk camilan Lada Bits</small>
    </div>
    <button class="btn btn-dark rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#modalTambahKategori">
        <i class="fa-solid fa-plus me-2"></i> Tambah Kategori
    </button>
</div>

<div class="card border-0 shadow-sm rounded-4 p-4" style="background-color: #E9ECEF;">
    <div id="alertContainer"></div>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-uppercase" style="font-size: 12px; letter-spacing: 0.5px;">
                <tr>
                    <th style="width: 80px;">#</th>
                    <th>Nama Kategori</th>
                    <th class="text-end" style="width: 150px;">Aksi</th>
                </tr>
            </thead>
            <tbody id="kategoriTableBody">
                <tr>
                    <td colspan="3" class="text-center text-muted py-3">Memuat data kategori...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="modalTambahKategori" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold">Tambah Kategori Baru</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formTambahKategori">
                <div class="modal-body py-4">
                    <div id="modalAlertContainer"></div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Nama Kategori</label>
                        <input type="text" id="namaKategori" class="form-control rounded-3" placeholder="Masukkan nama kategori baru" required>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-dark rounded-pill px-4">Simpan</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="modalEditKategori" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold">Edit Kategori</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formEditKategori">
                <div class="modal-body py-4">
                    <div id="modalEditAlertContainer"></div>
                    <input type="hidden" id="editKategoriId">
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Nama Kategori</label>
                        <input type="text" id="editNamaKategori" class="form-control rounded-3" placeholder="Masukkan nama kategori baru" required>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-dark rounded-pill px-4">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </div>
</div>

@push('scripts')
<script>
    // NAMA VARIABEL DIUBAH MENJADI apiToken AGAR TIDAK BENTROK
    const apiToken = localStorage.getItem('auth_token');
    const tableBody = document.getElementById('kategoriTableBody');
    const formTambah = document.getElementById('formTambahKategori');
    const alertContainer = document.getElementById('alertContainer');

    // 1. READ: Menampilkan Data Kategori dari API Backend
    async function loadCategories() {
        try {
            const response = await fetch('/api/categories', {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${apiToken}`, // Variabel disesuaikan
                    'Accept': 'application/json'
                }
            });

            const result = await response.json();

            if (response.ok) {
                let htmlContent = '';
                if (result.data.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-muted py-3">Belum ada kategori.</td></tr>`;
                    return;
                }

                result.data.forEach((category, index) => {
                    htmlContent += `
                        <tr>
                            <td>${index + 1}</td>
                            <td class="fw-bold">${category.name}</td>
                            <td class="text-end">
                                <button class="btn btn-sm btn-outline-dark border-0 me-1" onclick="openEditModal(${category.id}, '${category.name}')" title="Edit">
                                    <i class="fa-solid fa-pen-to-square"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-danger border-0" onclick="deleteCategory(${category.id}, '${category.name}')" title="Hapus">
                                    <i class="fa-solid fa-xmark fs-5"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                });
                tableBody.innerHTML = htmlContent;
            } else {
                tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger py-3">Gagal mengambil data dari server.</td></tr>`;
            }
        } catch (error) {
            console.error(error);
            tableBody.innerHTML = `<tr><td colspan="3" class="text-center text-danger py-3">Terjadi kesalahan jaringan.</td></tr>`;
        }
    }

    // 2. CREATE: Menambah Kategori Baru via Modal
    formTambah.addEventListener('submit', async (e) => {
        e.preventDefault();
        const name = document.getElementById('namaKategori').value;
        const modalAlertContainer = document.getElementById('modalAlertContainer');

        try {
            const response = await fetch('/api/categories', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${apiToken}`, // Variabel disesuaikan
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ name })
            });

            const result = await response.json();

            if (response.ok) {
                // Reset form input
                formTambah.reset();
                
                // Tutup Modal secara otomatis
                const modalElement = document.getElementById('modalTambahKategori');
                const modalInstance = bootstrap.Modal.getInstance(modalElement);
                modalInstance.hide();

                // Munculkan notifikasi sukses di halaman utama
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Kategori "${name}" berhasil ditambahkan!</div>`;
                
                // Reload tabel agar data terbaru muncul
                loadCategories();
            } else {
                modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">${result.message}</div>`;
            }
        } catch (error) {
            modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Gagal terhubung ke server.</div>`;
        }
    });

    // 3. DELETE: Menghapus Kategori
    async function deleteCategory(id, name) {
        if (!confirm(`Apakah Anda yakin ingin menghapus kategori "${name}"?`)) return;

        try {
            const response = await fetch(`/api/categories/${id}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${apiToken}`, // Variabel disesuaikan
                    'Accept': 'application/json'
                }
            });

            if (response.ok) {
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Kategori "${name}" berhasil dihapus.</div>`;
                loadCategories();
            } else {
                alertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Gagal menghapus kategori.</div>`;
            }
        } catch (error) {
            alertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Terjadi kesalahan jaringan.</div>`;
        }
    }

    // 4. UPDATE: Edit Kategori
    const formEdit = document.getElementById('formEditKategori');
    let editModalInstance = null;

    function openEditModal(id, name) {
        document.getElementById('editKategoriId').value = id;
        document.getElementById('editNamaKategori').value = name;
        document.getElementById('modalEditAlertContainer').innerHTML = '';
        
        const modalElement = document.getElementById('modalEditKategori');
        editModalInstance = new bootstrap.Modal(modalElement);
        editModalInstance.show();
    }

    formEdit.addEventListener('submit', async (e) => {
        e.preventDefault();
        const id = document.getElementById('editKategoriId').value;
        const name = document.getElementById('editNamaKategori').value;
        const modalAlertContainer = document.getElementById('modalEditAlertContainer');

        try {
            const response = await fetch(`/api/categories/${id}`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${apiToken}`,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ name })
            });

            const result = await response.json();

            if (response.ok) {
                if(editModalInstance) editModalInstance.hide();
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Kategori berhasil diperbarui menjadi "${name}"!</div>`;
                loadCategories();
            } else {
                modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">${result.message}</div>`;
            }
        } catch (error) {
            modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Gagal terhubung ke server.</div>`;
        }
    });

    // Jalankan fungsi otomatis saat halaman dimuat
    loadCategories();
</script>
@endpush
@endsection