@extends('layouts.admin')

@section('title', 'Dashboard')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-0">Dashboard Overview</h3>
            <small class="text-muted">Ringkasan aktivitas toko Lada Bits Anda hari ini</small>
        </div>
        <a href="{{ route('admin.reports.download') }}" class="btn btn-dark rounded-pill px-4" id="btnDownloadLaporan">
            <i class="fa-solid fa-download me-2"></i> Download Laporan CSV
        </a>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card p-3 border-0 shadow-sm rounded-4" style="background-color: #E9ECEF;">
                <div class="text-dark text-uppercase fw-bold" style="font-size: 11px;">Total Kategori</div>
                <div class="d-flex align-items-center mt-1">
                    <div class="fs-1 fw-bold me-2" id="countKategori">0</div>
                    <div style="width: 5px; height: 35px; background-color: blue; border-radius: 10px;"></div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 border-0 shadow-sm rounded-4" style="background-color: #E9ECEF;">
                <div class="text-dark text-uppercase fw-bold" style="font-size: 11px;">Total Produk</div>
                <div class="d-flex align-items-center mt-1">
                    <div class="fs-1 fw-bold me-2" id="countProduk">0</div>
                    <div style="width: 5px; height: 35px; background-color: green; border-radius: 10px;"></div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 border-0 shadow-sm rounded-4" style="background-color: #E9ECEF;">
                <div class="text-dark text-uppercase fw-bold" style="font-size: 11px;">Total Pesanan</div>
                <div class="d-flex align-items-center mt-1">
                    <div class="fs-1 fw-bold me-2" id="countPesanan">0</div>
                    <div style="width: 5px; height: 35px; background-color: yellow; border-radius: 10px;"></div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card p-3 border-0 shadow-sm rounded-4" style="background-color: #E9ECEF;">
                <div class="text-dark text-uppercase fw-bold" style="font-size: 11px;">Total Pelanggan</div>
                <div class="d-flex align-items-center mt-1">
                    <div class="fs-1 fw-bold me-2" id="countPelanggan">0</div>
                    <div style="width: 5px; height: 35px; background-color: orange; border-radius: 10px;"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-md-8">
            <div class="card p-4 shadow-sm border-0 rounded-4" style="background-color: #E9ECEF; min-height: 400px;">
                <div class="d-flex justify-content-center align-items-center h-100">
                    <div class="text-center">
                        <i class="fa-solid fa-chart-line fs-1 text-muted mb-3"></i>
                        <h4 class="fw-bold mb-0 text-muted">Laporan Statistik Penjualan</h4>
                        <small class="text-muted">(Akan diintegrasikan setelah ada data transaksi dari pelanggan)</small>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="card p-4 shadow-sm border-0 rounded-4" style="background-color: #fff; min-height: 400px; border-top: 5px solid #ffca2c !important;">
                <div class="d-flex align-items-center mb-3">
                    <div class="bg-warning bg-opacity-25 p-2 rounded-circle me-3 d-flex justify-content-center align-items-center" style="width: 40px; height: 40px;">
                        <i class="fa-solid fa-triangle-exclamation text-warning fs-5"></i>
                    </div>
                    <div>
                        <h5 class="fw-bold mb-0">Peringatan Stok</h5>
                        <small class="text-muted" style="font-size: 11px;">Produk sisa &le; 10 item</small>
                    </div>
                </div>
                
                <div id="lowStockContainer" class="overflow-auto pe-2" style="max-height: 280px;">
                    <div class="d-flex justify-content-center align-items-center h-100 text-muted small py-5">
                        Memuat data stok...
                    </div>
                </div>
            </div>
        </div>
    </div>

    @push('scripts')
    <script>
        const apiToken = localStorage.getItem('auth_token');

        // Fungsi 1: Load Angka Ringkasan (Sementara kita pertahankan yang pesanan dulu)
        async function loadDashboardStats() {
            try {
                const response = await fetch('/api/reports', {
                    method: 'GET',
                    headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' }
                });
                const result = await response.json();
                if (response.ok) {
                    const ringkasan = result.ringkasan;
                    const pesananEl = document.getElementById('countPesanan');
                    const kategoriEl = document.getElementById('countKategori');
                    const produkEl = document.getElementById('countProduk');
                    const pelangganEl = document.getElementById('countPelanggan');

                    if (pesananEl) pesananEl.innerText = ringkasan.total_pesanan;
                    if (kategoriEl) kategoriEl.innerText = ringkasan.total_kategori;
                    if (produkEl) produkEl.innerText = ringkasan.total_produk;
                    if (pelangganEl) pelangganEl.innerText = ringkasan.total_pelanggan;
                }
            } catch (error) { console.error("Gagal memuat statistik:", error); }
        }

        // Fungsi 2: Load Data Stok Menipis
        async function loadLowStockWarning() {
            try {
                const response = await fetch('/api/products', {
                    method: 'GET',
                    headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' }
                });
                
                const result = await response.json();
                const container = document.getElementById('lowStockContainer');

                if (response.ok) {
                    // FILTER: Ambil yang stoknya 10 ke bawah saja
                    const lowStockProducts = result.data.filter(p => p.stok <= 10);
                    
                    // Jika stok aman semua
                    if (lowStockProducts.length === 0) {
                        container.innerHTML = `
                            <div class="text-center py-5">
                                <i class="fa-solid fa-circle-check text-success fs-1 mb-3"></i>
                                <h6 class="fw-bold mb-1">Stok Aman Terkendali!</h6>
                                <p class="text-muted small mb-0">Semua produk Lada Bits tersedia di atas 10 item.</p>
                            </div>
                        `;
                        return;
                    }

                    // SORT: Urutkan dari stok yang paling sedikit (0 ke atas)
                    lowStockProducts.sort((a, b) => a.stok - b.stok);

                    // RENDER HTML LIST
                    let html = '<ul class="list-group list-group-flush">';
                    lowStockProducts.forEach(p => {
                        const isHabis = p.stok == 0;
                        const badgeColor = isHabis ? 'bg-danger' : 'bg-warning text-dark';
                        const textColor = isHabis ? 'text-danger fw-bold' : 'text-dark fw-bold';
                        const statusText = isHabis ? 'HABIS' : `Sisa ${p.stok}`;

                        html += `
                            <li class="list-group-item px-0 py-3 d-flex justify-content-between align-items-center border-bottom border-light">
                                <div class="d-flex flex-column">
                                    <span class="${textColor}" style="font-size: 14px;">${p.nama_produk}</span>
                                    <small class="text-muted" style="font-size: 11px;">${p.category ? p.category.name : 'Tanpa Kategori'}</small>
                                </div>
                                <span class="badge ${badgeColor} rounded-pill px-3 py-2 shadow-sm">${statusText}</span>
                            </li>
                        `;
                    });
                    html += '</ul>';
                    container.innerHTML = html;
                }
            } catch (error) {
                document.getElementById('lowStockContainer').innerHTML = `
                    <div class="text-center py-5 text-danger">
                        <i class="fa-solid fa-triangle-exclamation fs-3 mb-2"></i>
                        <p class="small mb-0">Gagal terhubung ke server database.</p>
                    </div>`;
            }
        }

        // Jalankan kedua fungsi secara paralel saat halaman dibuka
        loadDashboardStats();
        loadLowStockWarning();
    </script>
    @endpush
@endsection