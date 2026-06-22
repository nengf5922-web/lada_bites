import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Ditambahkan untuk kIsWeb
import '../providers/cart_provider.dart';
import '../services/product_api_service.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'history_screen.dart'; 
import 'akun_screen.dart';
import 'produk_kategori_screen.dart'; 

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final int _selectedIndex = 1; 
  final ProductApiService _apiService = ProductApiService();
  
  bool _isLoading = true;
  List<dynamic> _kategoriLengkap = [];

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    try {
      final response = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _kategoriLengkap = response.data['data'] ?? response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat kategori: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatImageUrl(String img) {
    if (img.isEmpty) return '';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (img.startsWith('http://127.0.0.1') || img.startsWith('http://localhost')) {
        return img.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
      } else if (!img.startsWith('http')) {
        return 'http://10.0.2.2:8000/storage/' + img;
      }
    } else {
      if (!img.startsWith('http')) {
        return 'http://127.0.0.1:8000/api/image/' + img;
      } else if (img.contains('/storage/')) {
        return img.replaceAll('/storage/', '/api/image/');
      }
    }
    return img;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Widget nextScreen;
    switch (index) {
      case 0: nextScreen = const HomeScreen(); break;
      case 2: nextScreen = const CartScreen(); break;
      case 3: nextScreen = const HistoryScreen(); break; 
      case 4: nextScreen = const AkunScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().cartCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD80309), Color(0xFFF73E3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Kategori Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))
        : _kategoriLengkap.isEmpty
          ? const Center(child: Text('Belum ada kategori.', style: TextStyle(color: Colors.black54)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _kategoriLengkap.length,
              itemBuilder: (context, index) {
                final kategori = _kategoriLengkap[index];
                final String imgRaw = kategori['image'] ?? '';
                final String imgUrl = _formatImageUrl(imgRaw);
                
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProdukKategoriScreen(namaKategori: kategori['name']),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16), 
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF5F5), 
                            shape: BoxShape.circle,
                          ),
                          child: imgUrl.isNotEmpty 
                              ? ClipOval(
                                  child: Image.network(
                                    imgUrl, 
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 40, color: Color(0xFFD80309)),
                                  ),
                                )
                              : const Icon(Icons.category, size: 40, color: Color(0xFFD80309)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          kategori['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111111), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      
      // === NAVIGASI BAWAH ===
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFFFFF5F5), 
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return const TextStyle(color: Color(0xFFD80309), fontSize: 12, fontWeight: FontWeight.bold);
              return const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return const IconThemeData(color: Color(0xFFD80309), size: 26);
              return const IconThemeData(color: Color(0xFFD80309), size: 24);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            animationDuration: const Duration(milliseconds: 400),
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_filled), label: 'Home'),
              const NavigationDestination(icon: Icon(Icons.grid_view), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Kategori'),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cartCount > 0, 
                  label: Text('$cartCount', style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFFD80309),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount', style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFFD80309),
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Keranjang',
              ),
              const NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.manage_history), label: 'Riwayat'),
              const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Akun'),
            ],
          ),
        ),
      ),
    );
  }
}