@extends('layouts.admin')

@section('title', 'Manajemen Ongkir')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h3 class="fw-bold mb-0">Pengaturan Ongkos Kirim</h3>
        <small class="text-muted">Kelola tarif ongkos kirim berdasarkan wilayah / daerah</small>
    </div>
    <button class="btn btn-dark rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#modalTambahOngkir">
        <i class="fa-solid fa-plus me-2"></i> Tambah Wilayah
    </button>
</div>

<div class="card border-0 shadow-sm rounded-4 p-4" style="background-color: #E9ECEF;">
    <div id="alertContainer"></div>
    <div class="table-responsive">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light text-uppercase" style="font-size: 12px; letter-spacing: 0.5px;">
                <tr>
                    <th style="width: 80px;">#</th>
                    <th>Wilayah / Daerah</th>
                    <th>Tarif (Rp)</th>
                    <th class="text-end" style="width: 150px;">Aksi</th>
                </tr>
            </thead>
            <tbody id="ongkirTableBody">
                <tr>
                    <td colspan="4" class="text-center text-muted py-3">Memuat data ongkir...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Tambah -->
<div class="modal fade" id="modalTambahOngkir" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold">Tambah Wilayah Baru</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formTambahOngkir">
                <div class="modal-body py-4">
                    <div id="modalAlertContainer"></div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Nama Wilayah</label>
                        <input type="text" id="namaWilayah" class="form-control rounded-3" placeholder="Misal: Jawa Barat" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Tarif (Rp)</label>
                        <input type="number" id="tarifOngkir" class="form-control rounded-3" placeholder="Misal: 15000" min="0" required>
                    </div>
                </div>
                <div class="modal-footer border-0 pb-4 pe-4">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-dark rounded-pill px-4">Simpan</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal Edit -->
<div class="modal fade" id="modalEditOngkir" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4 py-3">
                <h5 class="modal-title fw-bold">Edit Wilayah</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="formEditOngkir">
                <div class="modal-body py-4">
                    <div id="modalEditAlertContainer"></div>
                    <input type="hidden" id="editOngkirId">
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Nama Wilayah</label>
                        <input type="text" id="editNamaWilayah" class="form-control rounded-3" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-bold text-uppercase text-muted">Tarif (Rp)</label>
                        <input type="number" id="editTarifOngkir" class="form-control rounded-3" min="0" required>
                    </div>
                </div>
                <div class="modal-footer border-0 pb-4 pe-4">
                    <button type="button" class="btn btn-light rounded-pill px-4" data-bs-dismiss="modal">Batal</button>
                    <button type="submit" class="btn btn-dark rounded-pill px-4">Perbarui</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const apiToken = localStorage.getItem('auth_token');
    const tableBody = document.getElementById('ongkirTableBody');
    const alertContainer = document.getElementById('alertContainer');

    // Load Rates
    async function loadRates() {
        try {
            const response = await fetch('/api/shipping-rates');
            const data = await response.json();
            
            tableBody.innerHTML = '';
            
            if (data.length === 0) {
                tableBody.innerHTML = `<tr><td colspan="4" class="text-center py-3 text-muted">Belum ada data wilayah pengiriman.</td></tr>`;
                return;
            }

            data.forEach((rate, index) => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td class="fw-bold text-muted">${index + 1}</td>
                    <td class="fw-bold">${rate.wilayah}</td>
                    <td class="text-danger fw-bold">Rp ${parseInt(rate.tarif).toLocaleString('id-ID')}</td>
                    <td class="text-end">
                        <button class="btn btn-sm btn-light border me-1 rounded-3" onclick="openEditModal(${rate.id}, '${rate.wilayah.replace(/'/g, "\\'")}', ${rate.tarif})">
                            <i class="fa-solid fa-pen text-secondary"></i>
                        </button>
                        <button class="btn btn-sm btn-light border rounded-3" onclick="deleteRate(${rate.id}, '${rate.wilayah.replace(/'/g, "\\'")}')">
                            <i class="fa-solid fa-trash text-danger"></i>
                        </button>
                    </td>
                `;
                tableBody.appendChild(tr);
            });
        } catch (error) {
            tableBody.innerHTML = `<tr><td colspan="4" class="text-center py-3 text-danger">Gagal memuat data.</td></tr>`;
        }
    }

    loadRates();

    // Create Rate
    const formTambah = document.getElementById('formTambahOngkir');
    formTambah.addEventListener('submit', async (e) => {
        e.preventDefault();
        const wilayah = document.getElementById('namaWilayah').value;
        const tarif = document.getElementById('tarifOngkir').value;
        const modalAlertContainer = document.getElementById('modalAlertContainer');

        try {
            const response = await fetch('/api/shipping-rates', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${apiToken}`,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ wilayah, tarif })
            });

            const result = await response.json();

            if (response.ok) {
                formTambah.reset();
                bootstrap.Modal.getInstance(document.getElementById('modalTambahOngkir')).hide();
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Wilayah berhasil ditambahkan!</div>`;
                loadRates();
            } else {
                modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">${result.message || 'Gagal menambahkan wilayah.'}</div>`;
            }
        } catch (error) {
            modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Terjadi kesalahan jaringan.</div>`;
        }
    });

    // Update Rate
    window.openEditModal = (id, wilayah, tarif) => {
        document.getElementById('editOngkirId').value = id;
        document.getElementById('editNamaWilayah').value = wilayah;
        document.getElementById('editTarifOngkir').value = tarif;
        document.getElementById('modalEditAlertContainer').innerHTML = '';
        new bootstrap.Modal(document.getElementById('modalEditOngkir')).show();
    };

    const formEdit = document.getElementById('formEditOngkir');
    formEdit.addEventListener('submit', async (e) => {
        e.preventDefault();
        const id = document.getElementById('editOngkirId').value;
        const wilayah = document.getElementById('editNamaWilayah').value;
        const tarif = document.getElementById('editTarifOngkir').value;
        const modalAlertContainer = document.getElementById('modalEditAlertContainer');

        try {
            const response = await fetch(`/api/shipping-rates/${id}`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${apiToken}`,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ wilayah, tarif })
            });

            if (response.ok) {
                bootstrap.Modal.getInstance(document.getElementById('modalEditOngkir')).hide();
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Wilayah berhasil diperbarui!</div>`;
                loadRates();
            } else {
                const result = await response.json();
                modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">${result.message || 'Gagal memperbarui.'}</div>`;
            }
        } catch (error) {
            modalAlertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Terjadi kesalahan jaringan.</div>`;
        }
    });

    // Delete Rate
    window.deleteRate = async (id, wilayah) => {
        if (!confirm(`Apakah Anda yakin ingin menghapus tarif untuk ${wilayah}?`)) return;

        try {
            const response = await fetch(`/api/shipping-rates/${id}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${apiToken}`,
                    'Accept': 'application/json'
                }
            });

            if (response.ok) {
                alertContainer.innerHTML = `<div class="alert alert-success border-0 rounded-3 small py-2">Wilayah "${wilayah}" berhasil dihapus.</div>`;
                loadRates();
            } else {
                alertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Gagal menghapus wilayah.</div>`;
            }
        } catch (error) {
            alertContainer.innerHTML = `<div class="alert alert-danger border-0 rounded-3 small py-2">Terjadi kesalahan jaringan.</div>`;
        }
    };
});
</script>
@endsection
