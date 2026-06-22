import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  // Tempat menyimpan semua produk yang dimasukkan ke keranjang
  final List<Map<String, dynamic>> _items = [];

  // Getter untuk mengambil data keranjang
  List<Map<String, dynamic>> get items => _items;

  // Getter untuk menghitung jumlah total tipe barang (untuk badge angka merah)
  int get cartCount => _items.length;

  // Menghitung total harga HANYA untuk produk yang dicentang
  int get totalBelanja {
    int total = 0;
    for (var item in _items) {
      if (item['terpilih'] == true) {
        total += (item['harga'] as int) * (item['jumlah'] as int);
      }
    }
    return total;
  }

  // Cek apakah semua item dicentang
  bool get isSemuaTerpilih => _items.isNotEmpty && _items.every((item) => item['terpilih'] == true);

  // Cek apakah ada minimal satu item yang dicentang
  bool get isAdaYangDipilih => _items.any((item) => item['terpilih'] == true);

  // === FUNGSI MENAMBAH BARANG KE KERANJANG ===
  void tambahKeKeranjang(Map<String, dynamic> produk) {
    // Cek apakah barang sudah ada di keranjang sebelumnya
    int index = _items.indexWhere((item) => item['nama'] == produk['nama']);
    
    if (index != -1) {
      // Jika sudah ada, tambahkan jumlah quantity-nya saja
      _items[index]['jumlah'] += 1;
    } else {
      // Jika belum ada, masukkan sebagai barang baru dan otomatis tercentang
      _items.add({
        "id": produk['id'], // Menyimpan ID untuk sinkronisasi pesanan ke backend
        "nama": produk['nama'],
        "harga": produk['harga'],
        "jumlah": produk['jumlah'] ?? 1,
        "gambar": produk['gambar'] ?? '',
        "terpilih": true, 
      });
    }
    // Perintah sakti untuk memberitahu seluruh layar UI agar melakukan update/refresh
    notifyListeners();
  }

  // === FUNGSI UBAH JUMLAH (PLUS/MINUS) ===
  void ubahJumlah(int index, int delta) {
    _items[index]['jumlah'] += delta;
    // Jika jumlahnya 0, hapus dari keranjang
    if (_items[index]['jumlah'] <= 0) {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  // === FUNGSI CEKLIS/CENTANG SATUAN ===
  void toggleTerpilih(int index, bool value) {
    _items[index]['terpilih'] = value;
    notifyListeners();
  }

  // === FUNGSI CEKLIS/CENTANG SEMUA ALAT TOKOPEDIA ===
  void togglePilihSemua(bool value) {
    for (var item in _items) {
      item['terpilih'] = value;
    }
    notifyListeners();
  }

  // === FUNGSI BERSIHKAN KERANJANG SETELAH SUKSES CHECKOUT ===
  void hapusItemYangDicheckout() {
    _items.removeWhere((item) => item['terpilih'] == true);
    notifyListeners();
  }
}