import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import '../services/review_api_service.dart';

class ProdukDetailScreen extends StatefulWidget {
  final Map<String, dynamic> produk;

  const ProdukDetailScreen({super.key, required this.produk});

  @override
  State<ProdukDetailScreen> createState() => _ProdukDetailScreenState();
}

class _ProdukDetailScreenState extends State<ProdukDetailScreen> {
  final ReviewApiService _reviewApiService = ReviewApiService();
  List<Map<String, dynamic>> _ulasanList = [];
  bool _isLoadingReviews = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    // Default fallback jika data rating sebelumnya tidak ada
    _averageRating = (widget.produk['rating'] ?? 0).toDouble();
    _totalReviews = widget.produk['ulasan'] ?? 0;
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await _reviewApiService.getProductReviews(widget.produk['id']);
      if (mounted) {
        setState(() {
          _averageRating = response.data['average_rating']?.toDouble() ?? 0.0;
          _totalReviews = response.data['total_reviews'] ?? 0;
          _ulasanList = List<Map<String, dynamic>>.from(response.data['reviews']);
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Produk', style: TextStyle(color: Color(0xFF111111), fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF111111)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF111111)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Produk Besar
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF5F5),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, size: 100, color: Colors.black12),
              ),
            ),
            
            // 2. Info Utama Produk
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.produk['nama'],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111111)),
                        ),
                      ),
                      const Icon(Icons.favorite_border, color: Colors.grey, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.produk['harga']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFD80309)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFF111111), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_averageRating',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($_totalReviews Ulasan)',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Stok Tersedia', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), 

            // 3. Deskripsi Produk
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deskripsi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                  const SizedBox(height: 12),
                  Text(
                    'Nikmati sensasi renyah dan gurih dari ${widget.produk['nama']} khas Lada Bits! Dibuat dari bahan pilihan berkualitas dengan bumbu rahasia yang bikin nagih terus.\n\n'
                    '• Berat Bersih: 250 gram\n'
                    '• Kemasan: Standing Pouch Ziplock (Aman disimpan kembali)\n'
                    '• Ketahanan: 3 Bulan di suhu ruang\n\n'
                    'Sangat cocok untuk menemani waktu santai Kakak sambil nonton film, nugas, atau kumpul bareng teman. Hati-hati kepedesan dan ketagihan! 🔥',
                    style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), 

            // 4. Bagian Ulasan Pelanggan
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ulasan Pelanggan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                  const SizedBox(height: 16),
                  
                  if (_isLoadingReviews)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFFD80309)),
                    ))
                  else if (_ulasanList.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Belum ada ulasan untuk produk ini.', style: TextStyle(color: Colors.grey)),
                    ))
                  else
                    ..._ulasanList.map((ulasan) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey.shade300,
                                  backgroundImage: ulasan['user_image'] != null 
                                      ? NetworkImage(ulasan['user_image'])
                                      : null,
                                  child: ulasan['user_image'] == null 
                                      ? const Icon(Icons.person, color: Colors.white, size: 20) 
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(ulasan['user_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                                Text(ulasan['tanggal'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (index) => Icon(
                                index < (ulasan['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 14,
                              )),
                            ),
                            if (ulasan['comment'] != null && ulasan['comment'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(ulasan['comment'], style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                            ]
                          ],
                        ),
                      );
                    }).toList()
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Jarak kosong agar tidak tertutup bottom bar
          ],
        ),
      ),
      
      // 5. Bar Aksi Bawah (Keranjang & Beli)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFD80309)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk masuk ke keranjang! 🛒'), backgroundColor: Colors.green),
                    );
                  },
                  child: const Icon(Icons.add_shopping_cart, color: Color(0xFFD80309)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD80309),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(
                      produkDipilih: [
                        {
                          "id": widget.produk['id'],
                          "nama": widget.produk['nama'],
                          "harga": widget.produk['harga'],
                          "jumlah": 1,
                          "gambar": widget.produk['gambar'],
                        }
                      ],
                    )));
                  },
                  child: const Text('BELI SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}