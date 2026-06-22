import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class ProdukDetailScreen extends StatelessWidget {
  final Map<String, dynamic> produk;

  const ProdukDetailScreen({super.key, required this.produk});

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
                          produk['nama'],
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111111)),
                        ),
                      ),
                      const Icon(Icons.favorite_border, color: Colors.grey, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${produk['harga']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFD80309)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFF111111), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${produk['rating']}.0',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${produk['ulasan']} Ulasan)',
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
                    'Nikmati sensasi renyah dan gurih dari ${produk['nama']} khas Lada Bits! Dibuat dari bahan pilihan berkualitas dengan bumbu rahasia yang bikin nagih terus.\n\n'
                    '• Berat Bersih: 250 gram\n'
                    '• Kemasan: Standing Pouch Ziplock (Aman disimpan kembali)\n'
                    '• Ketahanan: 3 Bulan di suhu ruang\n\n'
                    'Sangat cocok untuk menemani waktu santai Kakak sambil nonton film, nugas, atau kumpul bareng teman. Hati-hati kepedesan dan ketagihan! 🔥',
                    style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
      
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