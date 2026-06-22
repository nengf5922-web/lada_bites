import 'package:flutter/foundation.dart';

class ProductModel {
  final int id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String gambar;
  final String kategoriNama; // Tambahan untuk membedakan kategori

  ProductModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategoriNama,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String img = json['gambar'] ?? json['image_url'] ?? '';
    if (img.isNotEmpty) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (img.startsWith('http://127.0.0.1') || img.startsWith('http://localhost')) {
          img = img.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
        } else if (!img.startsWith('http')) {
          img = 'http://10.0.2.2:8000/storage/' + img;
        }
      } else {
        // Untuk Chrome / Web
        if (!img.startsWith('http')) {
          img = 'http://127.0.0.1:8000/api/image/' + img;
        } else if (img.contains('/storage/')) {
          img = img.replaceAll('/storage/', '/api/image/');
        }
      }
    }

    String catName = '';
    if (json['category'] != null && json['category']['name'] != null) {
      catName = json['category']['name'];
    }

    return ProductModel(
      id: json['id'] ?? 0,
      nama: json['nama_produk'] ?? json['name'] ?? 'Produk Tanpa Nama',
      harga: int.tryParse(json['harga'].toString()) ?? json['price'] ?? 0,
      deskripsi: json['deskripsi'] ?? json['description'] ?? 'Tidak ada deskripsi',
      gambar: img, 
      kategoriNama: catName,
    );
  }
}