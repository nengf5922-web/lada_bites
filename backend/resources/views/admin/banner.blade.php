@extends('layouts.admin')

@section('title', 'Kelola Banner Promo')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-0">Banner Promo</h3>
            <small class="text-muted">Kelola gambar banner yang akan tampil di aplikasi pelanggan</small>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="card p-4 shadow-sm border-0 rounded-4" style="background-color: #fff;">
                <h5 class="fw-bold mb-3"><i class="fa-solid fa-cloud-arrow-up text-primary me-2"></i>Upload Banner</h5>
                <form id="formBanner" onsubmit="uploadBanner(event)">
                    <div class="mb-3">
                        <label class="form-label fw-bold" style="font-size: 13px;">Judul Promo</label>
                        <input type="text" id="judulBanner" class="form-control" placeholder="Contoh: Diskon Kemerdekaan" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold" style="font-size: 13px;">Pilih Gambar</label>
                        <input type="file" id="gambarBanner" class="form-control" accept="image/png, image/jpeg, image/jpg, image/webp" required>
                        <small class="text-muted" style="font-size: 11px;">Maksimal ukuran 2MB (Rekomendasi rasio 16:9)</small>
                    </div>
                    <button type="submit" class="btn btn-dark w-100 fw-bold rounded-3" id="btnUpload">Upload Sekarang</button>
                </form>
            </div>
        </div>

        <div class="col-md-8">
            <div class="card p-4 shadow-sm border-0 rounded-4" style="background-color: #E9ECEF; min-height: 400px;">
                <h5 class="fw-bold mb-3"><i class="fa-solid fa-images text-dark me-2"></i>Daftar Banner Aktif</h5>
                <div id="bannerContainer" class="row g-3">
                    <div class="text-center py-5 text-muted small w-100">Memuat data banner...</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Edit Banner -->
    <div class="modal fade" id="modalEditBanner" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                    <h5 class="modal-title fw-bold">Edit Banner</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="formEditBanner">
                    <div class="modal-body py-4">
                        <input type="hidden" id="editBannerId">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-uppercase text-muted">Judul Promo</label>
                            <input type="text" id="editJudulBanner" class="form-control rounded-3" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-uppercase text-muted">Gambar Baru (Opsional)</label>
                            <input type="file" id="editGambarBanner" class="form-control" accept="image/png, image/jpeg, image/jpg, image/webp">
                            <small class="text-muted" style="font-size: 11px;">Abaikan jika tidak ingin mengganti gambar.</small>
                        </div>
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="editStatusBanner">
                            <label class="form-check-label fw-bold" for="editStatusBanner">Banner Aktif</label>
                        </div>
                    </div>
                    <div class="modal-footer border-0 pt-0">
                        <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-dark rounded-pill px-4" id="btnSimpanEdit">Simpan</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    @push('scripts')
    <script>
        const apiToken = localStorage.getItem('auth_token');

        // Fungsi Memuat Daftar Banner
        async function loadBanners() {
            try {
                const response = await fetch('/api/admin/banners', {
                    method: 'GET',
                    headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' }
                });
                
                const result = await response.json();
                const container = document.getElementById('bannerContainer');

                if (response.ok) {
                    if (result.length === 0) {
                        container.innerHTML = `<div class="text-center py-5 text-muted small w-100">Belum ada banner yang diupload.</div>`;
                        return;
                    }

                    let html = '';
                    result.forEach(b => {
                        html += `
                            <div class="col-md-6">
                                <div class="card border-0 rounded-4 overflow-hidden shadow-sm h-100">
                                    <img src="${b.image_url}" class="card-img-top" alt="Banner" style="height: 120px; object-fit: cover;">
                                    <div class="card-body p-3 d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6 class="fw-bold mb-0 text-truncate" style="max-width: 150px; font-size: 14px;">${b.judul}</h6>
                                            <span class="badge bg-${b.is_active ? 'success' : 'secondary'} mt-1">${b.is_active ? 'Aktif' : 'Tidak Aktif'}</span>
                                        </div>
                                        <div>
                                            <button class="btn btn-sm btn-outline-dark border-0 me-1" onclick="openEditModal(${b.id}, '${b.judul}', ${b.is_active})" title="Edit">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger border-0" onclick="deleteBanner(${b.id})" title="Hapus">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                    container.innerHTML = html;
                }
            } catch (error) {
                console.error("Gagal memuat banner:", error);
            }
        }

        // Fungsi Upload Banner Baru
        async function uploadBanner(e) {
            e.preventDefault();
            const btn = document.getElementById('btnUpload');
            btn.innerHTML = 'Mengupload...';
            btn.disabled = true;

            const formData = new FormData();
            formData.append('judul', document.getElementById('judulBanner').value);
            formData.append('image', document.getElementById('gambarBanner').files[0]);

            try {
                const response = await fetch('/api/admin/banners', {
                    method: 'POST',
                    headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' },
                    body: formData
                });

                if (response.ok) {
                    alert('Banner berhasil diupload!');
                    document.getElementById('formBanner').reset();
                    loadBanners(); // Refresh daftar banner
                } else {
                    const errorData = await response.json();
                    alert('Gagal: ' + (errorData.message || 'Terjadi kesalahan'));
                }
            } catch (error) {
                alert('Terjadi kesalahan jaringan.');
            } finally {
                btn.innerHTML = 'Upload Sekarang';
                btn.disabled = false;
            }
        }

        // Fungsi Hapus Banner
        async function deleteBanner(id) {
            if (!confirm('Apakah Anda yakin ingin menghapus banner ini?')) return;

            try {
                const response = await fetch(`/api/admin/banners/${id}`, {
                    method: 'DELETE',
                    headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' }
                });

                if (response.ok) {
                    loadBanners(); // Refresh daftar banner
                } else {
                    alert('Gagal menghapus banner.');
                }
            } catch (error) {
                console.error("Error:", error);
            }
        }

        // Fungsi Edit Banner
        let editModalInstance = null;
        function openEditModal(id, judul, isActive) {
            document.getElementById('editBannerId').value = id;
            document.getElementById('editJudulBanner').value = judul;
            document.getElementById('editStatusBanner').checked = isActive === 1 || isActive === true;
            document.getElementById('editGambarBanner').value = '';

            const modalElement = document.getElementById('modalEditBanner');
            editModalInstance = new bootstrap.Modal(modalElement);
            editModalInstance.show();
        }

        document.getElementById('formEditBanner').addEventListener('submit', async (e) => {
            e.preventDefault();
            const btn = document.getElementById('btnSimpanEdit');
            btn.innerHTML = 'Menyimpan...';
            btn.disabled = true;

            const id = document.getElementById('editBannerId').value;
            const formData = new FormData();
            formData.append('judul', document.getElementById('editJudulBanner').value);
            formData.append('is_active', document.getElementById('editStatusBanner').checked ? 1 : 0);
            
            // Method PUT via POST
            formData.append('_method', 'PUT');

            const fileInput = document.getElementById('editGambarBanner');
            if (fileInput.files.length > 0) {
                formData.append('image', fileInput.files[0]);
            }

            try {
                const response = await fetch(`/api/admin/banners/${id}`, {
                    method: 'POST',
                    headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' },
                    body: formData
                });

                if (response.ok) {
                    if (editModalInstance) editModalInstance.hide();
                    alert('Banner berhasil diperbarui!');
                    loadBanners();
                } else {
                    const errorData = await response.json();
                    alert('Gagal: ' + (errorData.message || 'Terjadi kesalahan'));
                }
            } catch (error) {
                alert('Terjadi kesalahan jaringan.');
            } finally {
                btn.innerHTML = 'Simpan';
                btn.disabled = false;
            }
        });

        // Jalankan saat halaman dibuka
        loadBanners();
    </script>
    @endpush
@endsection