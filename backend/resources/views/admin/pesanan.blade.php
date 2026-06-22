@extends('layouts.admin')

@section('title', 'Kelola Pesanan')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h3 class="fw-bold mb-0">Kelola Pesanan</h3>
        <small class="text-muted">Pantau transaksi dan perbarui status pengiriman pesanan</small>
    </div>
</div>

<div class="card border-0 shadow-sm rounded-4 p-4" style="background-color: #E9ECEF;">
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-uppercase" style="font-size: 12px; letter-spacing: 0.5px;">
                <tr>
                    <th>Order ID</th>
                    <th>Pelanggan</th>
                    <th>Total Harga</th>
                    <th>Status</th>
                    <th>Tanggal</th>
                    <th class="text-end" style="width: 150px;">Aksi</th>
                </tr>
            </thead>
            <tbody id="pesananTableBody">
                <tr><td colspan="6" class="text-center text-muted py-3">Memuat data pesanan...</td></tr>
            </tbody>
        </table>
    </div>
</div>

<div class="modal fade" id="modalUpdateStatus" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold">Update Status Pesanan</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formUpdateStatus">
                <div class="modal-body py-4">
                    <div id="modalAlertContainer"></div>
                    <input type="hidden" id="order_id_update">
                    <input type="hidden" id="order_phone_update">
                    <input type="hidden" id="order_name_update">
                    <div class="alert alert-info border-0 rounded-3 small">
                        <i class="fa-brands fa-whatsapp me-2"></i> Status yang diperbarui akan otomatis membuat link WhatsApp untuk dikirimkan ke pelanggan.
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Status Pengiriman</label>
                        <select id="status_update" class="form-select rounded-3">
                            <option value="Belum Dibayar" disabled>Belum Dibayar</option>
                            <option value="menunggu pembayaran" disabled>Menunggu Pembayaran</option>
                            <option value="menunggu konfirmasi" disabled>Menunggu Konfirmasi</option>
                            <option value="Sudah Dibayar" disabled>Sudah Dibayar</option>
                            <option value="Diproses">Diproses / Dikemas</option>
                            <option value="Dikirim">Dikirim</option>
                            <option value="Selesai">Selesai</option>
                            <option value="Dibatalkan">Dibatalkan</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-success rounded-pill px-4"><i class="fa-brands fa-whatsapp me-2"></i> Update & Buat WA</button>
                </div>
            </form>
        </div>
        </div>
    </div>
</div>

<!-- Modal Lihat Bukti Pembayaran -->
<div class="modal fade" id="modalLihatBukti" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold">Bukti Pembayaran QRIS</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center py-4">
                <img id="imgBuktiPembayaran" src="" alt="Bukti Pembayaran" class="img-fluid rounded-3" style="max-height: 400px; object-fit: contain;">
            </div>
            <div class="modal-footer border-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Tutup</button>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
    const apiToken = localStorage.getItem('auth_token');
    const tableBody = document.getElementById('pesananTableBody');
    const formUpdate = document.getElementById('formUpdateStatus');

    // Fungsi format tanggal (opsional)
    function formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
    }

    async function loadOrders() {
        try {
            const res = await fetch('/api/admin/orders', {
                headers: { 'Authorization': `Bearer ${apiToken}`, 'Accept': 'application/json' }
            });
            const data = await res.json();
            
            if (res.ok) {
                if (data.length === 0) {
                    tableBody.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Belum ada pesanan.</td></tr>`;
                    return;
                }

                let html = '';
                data.forEach(order => {
                    let badgeColor = 'bg-secondary';
                    let st = order.status ? order.status.toLowerCase() : '';
                    if (st === 'pending' || st === 'menunggu pembayaran' || st === 'belum dibayar') badgeColor = 'bg-warning text-dark';
                    else if (st === 'menunggu konfirmasi') badgeColor = 'bg-primary';
                    else if (st === 'sudah dibayar') badgeColor = 'bg-primary';
                    else if (st === 'diproses' || st === 'dikemas') badgeColor = 'bg-info text-dark';
                    else if (st === 'dikirim') badgeColor = 'bg-info text-dark';
                    else if (st === 'selesai' || st === 'completed') badgeColor = 'bg-success';
                    else if (st === 'dibatalkan' || st === 'cancelled') badgeColor = 'bg-danger';

                    let btnBukti = '';
                    if (order.bukti_pembayaran) {
                        btnBukti = `<button class="btn btn-sm btn-outline-info border-0 me-1" title="Lihat Bukti Pembayaran" 
                                        onclick="lihatBukti('${order.bukti_pembayaran}')">
                                        <i class="fa-solid fa-image"></i>
                                    </button>`;
                    }

                    html += `
                        <tr>
                            <td class="fw-bold">#LB-${String(order.id).padStart(5, '0')}</td>
                            <td>
                                <div class="fw-bold">${order.nama_penerima}</div>
                                <small class="text-muted" style="font-size: 11px;">${(order.user && order.user.phone) ? order.user.phone : order.no_hp}</small>
                            </td>
                            <td class="fw-semibold">Rp ${parseInt(order.total_harga).toLocaleString('id-ID')}</td>
                            <td><span class="badge ${badgeColor} rounded-pill px-3 py-2">${order.status}</span></td>
                            <td>${formatDate(order.created_at)}</td>
                            <td class="text-end">
                                ${btnBukti}
                                <button class="btn btn-sm btn-outline-primary border-0 me-1" title="Update Status & Kirim WA" 
                                    onclick="openUpdateModal(${order.id}, '${order.status}', '${(order.user && order.user.phone) ? order.user.phone : order.no_hp}', '${order.nama_penerima}')">
                                    <i class="fa-solid fa-truck-fast"></i>
                                </button>
                                <!-- Opsional: tombol hapus pesanan jika diperlukan -->
                            </td>
                        </tr>
                    `;
                });
                tableBody.innerHTML = html;
            }
        } catch (e) {
            tableBody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">Gagal memuat data pesanan.</td></tr>`;
        }
    }

    function openUpdateModal(id, currentStatus, phone, name) {
        document.getElementById('order_id_update').value = id;
        document.getElementById('status_update').value = currentStatus;
        document.getElementById('order_phone_update').value = phone;
        document.getElementById('order_name_update').value = name;
        
        const modal = new bootstrap.Modal(document.getElementById('modalUpdateStatus'));
        modal.show();
    }

    function lihatBukti(url) {
        document.getElementById('imgBuktiPembayaran').src = url;
        const modal = new bootstrap.Modal(document.getElementById('modalLihatBukti'));
        modal.show();
    }

    formUpdate.addEventListener('submit', async (e) => {
        e.preventDefault();
        const id = document.getElementById('order_id_update').value;
        const status = document.getElementById('status_update').value;
        const phone = document.getElementById('order_phone_update').value;
        const name = document.getElementById('order_name_update').value;
        const alertBox = document.getElementById('modalAlertContainer');

        try {
            const res = await fetch(`/api/orders/${id}/status`, {
                method: 'PATCH',
                headers: { 
                    'Authorization': `Bearer ${apiToken}`, 
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ status: status })
            });

            if (res.ok) {
                // Tutup modal
                const modalEl = document.getElementById('modalUpdateStatus');
                const modal = bootstrap.Modal.getInstance(modalEl);
                modal.hide();
                
                // Refresh data
                await loadOrders(); // Tunggu loadOrders selesai

                // Generate WhatsApp Link
                if (phone && phone !== 'null' && phone !== 'undefined') {
                    let waPhone = phone.startsWith('0') ? '62' + phone.substring(1) : phone;
                    let message = `Halo Kak ${name},\n\nPesanan Lada Bits Anda saat ini berstatus: *${status}*.\nTerima kasih telah berbelanja di Lada Bits!`;
                    let waUrl = `https://wa.me/${waPhone}?text=${encodeURIComponent(message)}`;
                    window.open(waUrl, '_blank');
                }
            } else {
                const errData = await res.json().catch(() => ({}));
                alertBox.innerHTML = `<div class="alert alert-danger py-2">Gagal memperbarui status: ${errData.message || 'Error server'}</div>`;
            }
        } catch (e) {
            alertBox.innerHTML = `<div class="alert alert-danger py-2">Terjadi kesalahan jaringan.</div>`;
        }
    });

    loadOrders();
</script>
@endpush
@endsection