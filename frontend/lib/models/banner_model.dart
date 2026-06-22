import 'package:flutter/foundation.dart';

class BannerModel {
  final int id;
  final String judul;
  final String imageUrl;
  final bool isActive;

  BannerModel({
    required this.id, 
    required this.judul, 
    required this.imageUrl,
    this.isActive = true, // Default aktif jika tidak ada dari API
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String img = json['image_url'] ?? '';
    if (img.isNotEmpty) {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (img.startsWith('http://127.0.0.1') || img.startsWith('http://localhost')) {
          img = img.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
        } else if (!img.startsWith('http')) {
          img = 'http://10.0.2.2:8000/storage/' + img;
        }
      } else {
        // Untuk Chrome / Web bypass CORS
        if (!img.startsWith('http')) {
          img = 'http://127.0.0.1:8000/api/image/' + img;
        } else if (img.contains('/storage/')) {
          img = img.replaceAll('/storage/', '/api/image/');
        }
      }
    }

    return BannerModel(
      id: json['id'],
      judul: json['judul'] ?? '',
      imageUrl: img,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}