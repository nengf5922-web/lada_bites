@extends('layouts.admin')

@section('title', 'Manajemen Produk')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h3 class="fw-bold mb-0">Daftar Produk</h3>
        <small class="text-muted">Pantau ketersediaan stok dan harga camilan Lada Bits</small>
    </div>
    <button class="btn btn-dark rounded-pill px-4" onclick="openAddModal()">
        <i class="fa-solid fa-plus me-2"></i> Tambah Produk
    </button>
</div>

<div class="card border-0 shadow-sm rounded-4 p-4" style="background-color: #E9ECEF;">
    <div id="alertContainer"></div>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-uppercase" style="font-size: 12px; letter-spacing: 0.5px;">
                <tr>
                    <th style="width: 50px;">#</th>
                    <th>Nama Produk</th>
                    <th>Kategori</th>
                    <th>Harga</th>
                    <th style="width: 100px;">Stok</th>
                    <th style="width: 120px;">Status</th>
                    <th class="text-end" style="width: 100px;">Aksi</th>
                </tr>
            </thead>
            <tbody id="produkTableBody">
                <tr><td colspan="7" class="text-center text-muted py-3">Memuat data produk...</td></tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="modalTambahProduk" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold" id="modalTitle">Tambah Produk Baru</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formTambahProduk" enctype="multipart/form-data">
                <input type="hidden" id="product_id" value="">
                <div class="modal-body py-4">
                    <div id="modalAlertContainer"></div>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">NAMA PRODUK</label>
                                <input type="text" id="nama_produk" class="form-control rounded-3" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">KATEGORI</label>
                                <select id="category_id" class="form-select rounded-3" required>
                                    <option value="">Memuat kategori...</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">HARGA (Rp)</label>
                                <input type="number" id="harga" class="form-control rounded-3" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">STOK AWAL</label>
                                <input type="number" id="stok" class="form-control rounded-3" required>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">FOTO PRODUK</label>
                                <div class="d-flex align-items-center">
                                    <div id="imagePreviewContainer" class="me-3 d-none">
                                        <img id="imagePreview" src="" class="rounded-3 shadow-sm border border-2 border-white" style="width: 60px; height: 60px; object-fit: cover;">
                                    </div>
                                    <div class="flex-grow-1">
                                        <input type="file" id="gambar" class="form-control rounded-3" accept="image/png, image/jpeg, image/jpg, image/webp" onchange="previewImage(this)">
                                        <small class="text-muted" style="font-size: 11px;">Maksimal ukuran 10MB (Format: JPG, PNG, WEBP).</small>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold text-muted">DESKRIPSI (Opsional)</label>
                                <textarea id="deskripsi" class="form-control rounded-3" rows="2"></textarea>
                            </div>
                        </div>
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

@push('scripts')
<script>
    const apiToken = localStorage.getItem('auth_token');
    const tableBody = document.getElementById('produkTableBody');
    const formTambah = document.getElementById('formTambahProduk');
    const categorySelect = document.getElementById('category_id');
    const alertContainer = document.getElementById('alertContainer');
    let allProducts = [];

    // Fungsi membuka modal Tambah
    function openAddModal() {
        formTambah.reset();
        document.getElementById('product_id').value = '';
        document.getElementById('modalTitle').innerText = 'Tambah Produk Baru';
        document.getElementById('imagePreviewContainer').classList.add('d-none');
        document.getElementById('imagePreview').src = '';
        const modal = new bootstrap.Modal(document.getElementById('modalTambahProduk'));
        modal.show();
    }

    // 0. Preview Gambar saat dipilih
    function previewImage(input) {
        const previewContainer = document.getElementById('imagePreviewContainer');
        const previewImage = document.getElementById('imagePreview');
        
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                previewImage.src = e.target.result;
                previewContainer.classList.remove('d-none');
            }
            reader.readAsDataURL(input.files[0]);
        } else {
            previewImage.src = "";
            previewContainer.classList.add('d-none');
        }
    }

    // 1. Load Data Kategori untuk Dropdown
    async function loadCategoriesForDropdown() {
        try {
            const res = await fetch('/api/categories', { headers: { 'Authorization': `Bearer ${apiToken}` }});
            const result = await res.json();
            if (res.ok) {
                categorySelect.innerHTML = '<option value="">-- Pilih Kategori --</option>';
                result.data.forEach(c => categorySelect.innerHTML += `<option value="${c.id}">${c.name}</option>`);
            }
        } catch (e) { console.error('Gagal load kategori'); }
    }

    // 2. Load Data Produk & Logika Indikator Stok
    async function loadProducts() {
        try {
            const res = await fetch('/api/products', { headers: { 'Authorization': `Bearer ${apiToken}` }});
            const result = await res.json();
            
            if (res.ok) {
                let html = '';
                if(result.data.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="7" class="text-center text-muted py-3">Belum ada produk.</td></tr>`;
                    return;
                }
                
                allProducts = result.data;
                allProducts.forEach((p, i) => {
                    const catName = p.category ? p.category.name : '-';
                    
                    // --- LOGIKA INDIKATOR STOK ---
                    let statusBadge = '';
                    let stockColor = '';
                    
                    if (p.stok <= 0) {
                        statusBadge = '<span class="badge bg-danger rounded-pill px-3">Habis</span>';
                        stockColor = 'text-danger fw-bold';
                    } else if (p.stok <= 10) {
                        statusBadge = '<span class="badge bg-warning text-dark rounded-pill px-3">Menipis</span>';
                        stockColor = 'text-warning fw-bold';
                    } else {
                        statusBadge = '<span class="badge bg-success rounded-pill px-3">Aman</span>';
                        stockColor = 'text-success fw-bold';
                    }
                    // -----------------------------
                    
                    // --- LOGIKA URL GAMBAR ---
                    let imageUrl = p.gambar;
                    if (imageUrl && !imageUrl.startsWith('http')) {
                        // Jika tersimpan sebagai path relatif lama
                        imageUrl = `/storage/${imageUrl}`;
                    }
                    const imageHtml = imageUrl 
                        ? `<img src="${imageUrl}" class="rounded-3 me-3 shadow-sm border border-white border-2" style="width: 45px; height: 45px; object-fit: cover;">` 
                        : `<div class="rounded-3 me-3 bg-secondary bg-opacity-10 d-flex align-items-center justify-content-center text-muted border" style="width: 45px; height: 45px;"><i class="fa-solid fa-image"></i></div>`;
                    
                    html += `<tr>
                        <td>${i + 1}</td>
                        <td>
                            <div class="d-flex align-items-center">
                                ${imageHtml}
                                <span class="fw-bold">${p.nama_produk}</span>
                            </div>
                        </td>
                        <td><span class="badge bg-secondary">${catName}</span></td>
                        <td>Rp ${parseInt(p.harga).toLocaleString('id-ID')}</td>
                        <td class="fs-5 ${stockColor}">${p.stok}</td>
                        <td>${statusBadge}</td>
                        <td class="text-end">
                            <button class="btn btn-sm btn-outline-primary border-0 me-1" onclick="editProduct(${i})" title="Edit">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger border-0" onclick="deleteProduct(${p.id}, '${p.nama_produk}')" title="Hapus">
                                <i class="fa-solid fa-trash"></i>
                            </button>
                        </td>
                    </tr>`;
                });
                tableBody.innerHTML = html;
            }
        } catch (e) { 
            tableBody.innerHTML = `<tr><td colspan="7" class="text-center text-danger">Terjadi kesalahan jaringan.</td></tr>`; 
        }
    }

    // 3. Submit Produk (Tambah / Edit)
    formTambah.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const productId = document.getElementById('product_id').value;
        const formData = new FormData();
        
        if (productId) {
            formData.append('_method', 'PUT'); // Laravel trik untuk update via FormData
        }
        
        formData.append('nama_produk', document.getElementById('nama_produk').value);
        formData.append('category_id', document.getElementById('category_id').value);
        formData.append('harga', document.getElementById('harga').value);
        formData.append('stok', document.getElementById('stok').value);
        formData.append('deskripsi', document.getElementById('deskripsi').value);
        
        const fileGambar = document.getElementById('gambar').files[0];
        if (fileGambar) {
            formData.append('gambar', fileGambar);
        }
        
        try {
            const url = productId ? `/api/products/${productId}` : '/api/products';
            const res = await fetch(url, {
                method: 'POST',
                headers: { 
                    'Authorization': `Bearer ${apiToken}`,
                    'Accept': 'application/json'
                }, 
                body: formData
            });

            if (res.ok) {
                formTambah.reset();
                document.getElementById('imagePreviewContainer').classList.add('d-none');
                document.getElementById('imagePreview').src = '';
                
                bootstrap.Modal.getInstance(document.getElementById('modalTambahProduk')).hide();
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Produk berhasil ${productId ? 'diperbarui' : 'ditambahkan'}!</div>`;
                loadProducts();
            } else {
                const errorData = await res.json();
                let errorMessage = 'Gagal menyimpan produk. Pastikan data valid.';
                if (errorData.errors) {
                    errorMessage = Object.values(errorData.errors).flat().join('<br>');
                } else if (errorData.message) {
                    errorMessage = errorData.message;
                }
                document.getElementById('modalAlertContainer').innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">${errorMessage}</div>`;
            }
        } catch (e) { 
            document.getElementById('modalAlertContainer').innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Kesalahan jaringan.</div>`; 
        }
    });

    // 4. Edit Produk (Membuka Modal dengan Data)
    function editProduct(index) {
        const p = allProducts[index];
        
        document.getElementById('product_id').value = p.id;
        document.getElementById('modalTitle').innerText = 'Edit Produk';
        document.getElementById('nama_produk').value = p.nama_produk;
        document.getElementById('category_id').value = p.category_id;
        document.getElementById('harga').value = p.harga;
        document.getElementById('stok').value = p.stok;
        document.getElementById('deskripsi').value = p.deskripsi || '';
        
        const previewContainer = document.getElementById('imagePreviewContainer');
        const previewImage = document.getElementById('imagePreview');
        
        if (p.gambar) {
            let imageUrl = p.gambar;
            if (!imageUrl.startsWith('http')) imageUrl = `/storage/${imageUrl}`;
            previewImage.src = imageUrl;
            previewContainer.classList.remove('d-none');
        } else {
            previewImage.src = '';
            previewContainer.classList.add('d-none');
        }
        
        const modal = new bootstrap.Modal(document.getElementById('modalTambahProduk'));
        modal.show();
    }

    // 4. Hapus Produk
    async function deleteProduct(id, name) {
        if(!confirm(`Yakin ingin menghapus produk "${name}"?`)) return;
        await fetch(`/api/products/${id}`, { method: 'DELETE', headers: { 'Authorization': `Bearer ${apiToken}` }});
        loadProducts();
    }

    // Jalankan saat halaman dibuka
    loadCategoriesForDropdown();
    loadProducts();
</script>
@endpush
@endsection