import 'package:flutter/material.dart';
import '../../services/product_api_service.dart';
import '../../models/banner_model.dart';

class AdminBannerScreen extends StatefulWidget {
  const AdminBannerScreen({super.key});

  @override
  State<AdminBannerScreen> createState() => _AdminBannerScreenState();
}

class _AdminBannerScreenState extends State<AdminBannerScreen> {
  final ProductApiService _apiService = ProductApiService();
  List<BannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final response = await _apiService.getBanners();
      final List<dynamic> data = response.data['data'] ?? response.data;
      setState(() {
        _banners = data.map((json) => BannerModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat banner: $e');
      setState(() => _isLoading = false);
    }
  }

  void _uploadBannerBaru() {
    // Nanti di sini kita pasang library image_picker untuk ambil gambar dari Galeri HP/Laptop
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur pilih gambar & upload segera disambungkan ke API!'))
    );
  }

  void _hapusBanner(int id) {
    setState(() {
      _banners.removeWhere((banner) => banner.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banner berhasil dihapus!'), backgroundColor: Colors.red)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF111111), Color(0xFF333333)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Kelola Banner Promo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))
          : _banners.isEmpty
          ? const Center(child: Text('Belum ada banner aktif.', style: TextStyle(color: Colors.black54)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview Gambar Banner
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5), // Warna background seperti gambar Kakak
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (banner.imageUrl.isNotEmpty)
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(banner.imageUrl, fit: BoxFit.cover, width: double.infinity),
                                ),
                              )
                            else
                              const Expanded(
                                child: Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.black26)),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(banner.judul, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      // Action Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(banner.isActive ? Icons.check_circle : Icons.cancel, 
                                     color: banner.isActive ? Colors.green : Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(banner.isActive ? 'Aktif' : 'Nonaktif', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _hapusBanner(banner.id),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD80309),
        icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
        label: const Text('Upload Banner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _uploadBannerBaru,
      ),
    );
  }
}