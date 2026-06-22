import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../services/product_api_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'produk_detail_screen.dart';

class ProdukKategoriScreen extends StatefulWidget {
  final String namaKategori;

  const ProdukKategoriScreen({super.key, required this.namaKategori});

  @override
  State<ProdukKategoriScreen> createState() => _ProdukKategoriScreenState();
}

class _ProdukKategoriScreenState extends State<ProdukKategoriScreen> {
  final ProductApiService _apiService = ProductApiService();
  List<ProductModel> _produkKategori = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    try {
      final response = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          final List data = response.data['data'] ?? response.data;
          // Parse semua produk
          final allProducts = data.map((json) => ProductModel.fromJson(json)).toList();
          // Filter berdasarkan kategori
          _produkKategori = allProducts.where((p) => p.kategoriNama.toLowerCase() == widget.namaKategori.toLowerCase()).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat produk kategori: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD80309), 
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.namaKategori, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))
          : _produkKategori.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Belum ada produk untuk kategori ${widget.namaKategori}'),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65, 
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _produkKategori.length,
                  itemBuilder: (context, index) {
                    final produk = _produkKategori[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProdukDetailScreen(produk: {
                          'id': produk.id,
                          'nama_produk': produk.nama,
                          'harga': produk.harga,
                          'deskripsi': produk.deskripsi,
                          'gambar': produk.gambar,
                          'category': {'name': produk.kategoriNama}
                        })));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF5F5),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: produk.gambar.isNotEmpty 
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(
                                        produk.gambar, 
                                        fit: BoxFit.cover, 
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, color: Colors.black26, size: 40)),
                                      ),
                                    )
                                  : const Center(child: Icon(Icons.image_outlined, color: Colors.black26, size: 40)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(produk.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111111))),
                                  const SizedBox(height: 2),
                                  Text(
                                    produk.deskripsi.isEmpty ? 'Camilan lezat' : produk.deskripsi, 
                                    maxLines: 2, 
                                    overflow: TextOverflow.ellipsis, 
                                    style: const TextStyle(fontSize: 10, color: Colors.black54)
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Rp ${produk.harga}', style: const TextStyle(color: Color(0xFFD80309), fontWeight: FontWeight.w900, fontSize: 14)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 36,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFD80309),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () {
                                              context.read<CartProvider>().tambahKeKeranjang({
                                                "id": produk.id,
                                                "nama": produk.nama,
                                                "harga": produk.harga,
                                                "jumlah": 1,
                                                "gambar": produk.gambar,
                                              });
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                                            },
                                            child: const Text('Beli', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF111111),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () {
                                            context.read<CartProvider>().tambahKeKeranjang({
                                              "id": produk.id,
                                              "nama": produk.nama,
                                              "harga": produk.harga,
                                              "jumlah": 1,
                                              "gambar": produk.gambar,
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${produk.nama} ditambahkan ke keranjang!'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
                                            );
                                          },
                                          child: const Icon(Icons.add_shopping_cart, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}