import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart'; // Ditambahkan untuk kIsWeb
import '../services/product_api_service.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../providers/cart_provider.dart';
import 'kategori_screen.dart';
import 'cart_screen.dart';
import 'history_screen.dart';
import 'akun_screen.dart';
import 'produk_kategori_screen.dart'; // Ditambahkan untuk navigasi kategori dari Home
import 'produk_detail_screen.dart';
import 'checkout_screen.dart';
import '../services/user_api_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0; 

  final ProductApiService _apiService = ProductApiService();
  final UserApiService _userApiService = UserApiService();
  String _namaUser = '';

  List<BannerModel> _bannerList = [];
  List<ProductModel> _produkList = [];
  List<ProductModel> _filteredProdukList = [];
  List<dynamic> _kategoriList = [];

  bool _isLoadingBanner = true;
  bool _isLoadingProduk = true;
  bool _isLoadingKategori = true;

  int _currentBannerIndex = 0; 

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _fetchProfilUser();
    _fetchProduk();
    _fetchBanners();
    _fetchKategori();
  }

  Future<void> _fetchProfilUser() async {
    try {
      final response = await _userApiService.getUserProfile();
      if (mounted) {
        setState(() {
          final data = response.data['data'] ?? response.data;
          _namaUser = data['name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat nama user: $e');
    }
  }

  Future<void> _fetchBanners() async {
    try {
      final response = await _apiService.getBanners();
      if (mounted) {
        setState(() {
          final List data = response.data['data'] ?? response.data;
          _bannerList = data.map((json) => BannerModel.fromJson(json)).toList();
          _isLoadingBanner = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat banner: $e');
      if (mounted) setState(() => _isLoadingBanner = false);
    }
  }

  Future<void> _fetchProduk() async {
    try {
      final response = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          final List data = response.data['data'] ?? response.data;
          _produkList = data.map((json) => ProductModel.fromJson(json)).toList();
          _filteredProdukList = List.from(_produkList);
          _isLoadingProduk = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat produk: $e');
      if (mounted) setState(() => _isLoadingProduk = false);
    }
  }

  Future<void> _fetchKategori() async {
    try {
      final response = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _kategoriList = response.data['data'] ?? response.data;
          _isLoadingKategori = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat kategori: $e');
      if (mounted) setState(() => _isLoadingKategori = false);
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
      case 1: nextScreen = const KategoriScreen(); break;
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD80309), Color(0xFFF73E3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Image.asset('assets/logo.png', width: 28, height: 28, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 28)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lada Bits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                if (_namaUser.isNotEmpty)
                  Text('Selamat datang, $_namaUser', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  if (_searchQuery.isEmpty) {
                    _filteredProdukList = List.from(_produkList);
                  } else {
                    _filteredProdukList = _produkList
                        .where((p) => p.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari camilan pedas favoritmu...',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD80309)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [
          // === AREA BANNER ===
          if (_searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (_isLoadingBanner)
                    const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(height: 140, child: Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))),
                  )
                else if (_bannerList.isEmpty)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: screenWidth > 800 ? 3.5 : (screenWidth > 600 ? 2.5 : 2.0),
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 4),
                            autoPlayAnimationDuration: const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            viewportFraction: screenWidth > 800 ? 0.6 : (screenWidth > 600 ? 0.7 : 0.85),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentBannerIndex = index;
                              });
                            },
                          ),
                          items: [
                            _buildModernBanner(
                              title: 'PROMO SPESIAL',
                              headline: 'Diskon 20%',
                              subtitle: 'Khusus pengguna baru Lada Bits!',
                              icon: Icons.whatshot_rounded,
                              colors: [const Color(0xFFE52D27), const Color(0xFFB31217)],
                            ),
                            _buildModernBanner(
                              title: 'WEEKEND SALE',
                              headline: 'Beli 2 Gratis 1',
                              subtitle: 'Borong camilan buat akhir pekan.',
                              icon: Icons.celebration_rounded,
                              colors: [const Color(0xFF111111), const Color(0xFF333333)],
                              headlineColor: Colors.amber,
                            ),
                            _buildModernBanner(
                              title: 'BEBAS BIAYA',
                              headline: 'Gratis Ongkir',
                              subtitle: 'Minimal belanja Rp 50.000 saja.',
                              icon: Icons.local_shipping_rounded,
                              colors: [const Color(0xFFFF8008), const Color(0xFFFFC837)],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [0, 1, 2].map((index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentBannerIndex == index ? const Color(0xFFD80309) : Colors.grey.shade300,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CarouselSlider.builder(
                          itemCount: _bannerList.length,
                          itemBuilder: (context, index, realIndex) {
                            final banner = _bannerList[index];
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  banner.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFFFF5E1),
                                    child: Center(child: Icon(Icons.broken_image, color: Colors.grey.shade400)),
                                  ),
                                ),
                              ),
                            );
                          },
                            options: CarouselOptions(
                              aspectRatio: screenWidth > 800 ? 4.0 : (screenWidth > 600 ? 3.0 : 2.2),
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              viewportFraction: screenWidth > 800 ? 0.5 : (screenWidth > 600 ? 0.6 : 0.85),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentBannerIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_bannerList.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _bannerList.asMap().entries.map((entry) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentBannerIndex == entry.key
                                    ? const Color(0xFFD80309)
                                    : Colors.grey.shade300,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // === DAFTAR KATEGORI ===
          if (!_isLoadingKategori && _kategoriList.isNotEmpty && _searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text('Kategori Pilihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _kategoriList.length,
                      itemBuilder: (context, index) {
                        final kategori = _kategoriList[index];
                        final String imgRaw = kategori['image'] ?? '';
                        final String imgUrl = _formatImageUrl(imgRaw);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProdukKategoriScreen(namaKategori: kategori['name'])));
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF5F5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: imgUrl.isNotEmpty 
                                        ? ClipOval(
                                            child: Image.network(
                                              imgUrl,
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Color(0xFFD80309)),
                                            ),
                                          )
                                        : const Icon(Icons.category, color: Color(0xFFD80309)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    kategori['name'],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF111111)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // === JUDUL PRODUK ===
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Terpopuler', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111111))
              ),
            ),
          ),

          // === GRID PRODUK DARI API ===
          _isLoadingProduk 
            ? const SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFD80309))),
                ),
              )
            : _filteredProdukList.isEmpty
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('Produk tidak ditemukan', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.65, 
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final produk = _filteredProdukList[index];
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
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
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
                                        produk.deskripsi.isEmpty ? 'Camilan pedas lezat' : produk.deskripsi, 
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
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(
                                                    produkDipilih: [
                                                      {
                                                        "id": produk.id,
                                                        "nama": produk.nama,
                                                        "harga": produk.harga,
                                                        "jumlah": 1,
                                                        "gambar": produk.gambar,
                                                      }
                                                    ],
                                                  )));
                                                },
                                                child: const Text('Beli Sekarang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                      childCount: _searchQuery.isNotEmpty 
                          ? _filteredProdukList.length 
                          : (_filteredProdukList.length > 4 ? 4 : _filteredProdukList.length),
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),

      // === NAVIGASI BAWAH ===
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
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

  // Method bantuan untuk membuat desain banner modern
  Widget _buildModernBanner({
    required String title,
    required String headline,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    Color headlineColor = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi Shape
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Konten Teks
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: colors.first,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        headline,
                        style: TextStyle(color: headlineColor, fontWeight: FontWeight.w900, fontSize: 24),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.3)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}