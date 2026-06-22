import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_api_service.dart';
import '../services/user_api_service.dart';
import '../models/user_model.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'kategori_screen.dart';
import 'cart_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'alamat_pengiriman_screen.dart';
import 'edit_profile_screen.dart'; // Ditambahkan
import 'ulasan_screen.dart'; // Import Halaman Ulasan Baru
import 'pusat_bantuan_screen.dart'; // Import Halaman Pusat Bantuan Baru
import 'package:flutter/foundation.dart'; // Untuk kIsWeb dan TargetPlatform

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final int _selectedIndex = 4;

  final AuthApiService _authApiService = AuthApiService();
  final UserApiService _userApiService = UserApiService();
  bool _isLoading = true;

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchProfilUser();
  }

  Future<void> _fetchProfilUser() async {
    try {
      final response = await _userApiService.getUserProfile();

      if (mounted) {
        setState(() {
          final responseData = response.data['data'] ?? response.data;
          _currentUser = UserModel.fromJson(responseData);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  ImageProvider? _getProfileImage() {
    if (_currentUser?.profilePhoto != null && _currentUser!.profilePhoto!.isNotEmpty) {
      String img = _currentUser!.profilePhoto!;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
         if (img.startsWith('http://127.0.0.1') || img.startsWith('http://localhost')) {
            img = img.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
         } else if (!img.startsWith('http')) {
            img = 'http://10.0.2.2:8000/storage/' + img;
         }
      } else {
         if (!img.startsWith('http')) {
            img = 'http://127.0.0.1:8000/api/image/' + img;
         } else if (img.contains('/storage/')) {
            img = img.replaceAll('/storage/', '/api/image/');
         }
      }
      
      // Mencegah cache image dengan menambahkan timestamp (waktu sekarang)
      img = '$img?t=${DateTime.now().millisecondsSinceEpoch}';
      
      return NetworkImage(img);
    }
    return null;
  }

  void _prosesLogout() {
    showDialog(
      context: context,
      builder: (alertContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Keluar Akun',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Apakah Kakak yakin ingin keluar dari aplikasi Lada Bits?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext),
            child: const Text(
              'BATAL',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(alertContext); // Tutup dialog konfirmasi
              
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD80309)),
                ),
              );

              try {
                await _authApiService.logout();
              } catch (e) {
                debugPrint('Pesan error API logout: $e');
              } finally {
                await _authApiService.hapusToken();
                if (mounted) {
                  // Hapus semua screen termasuk loading dialog, lalu ke LoginScreen
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text(
              'YA, KELUAR',
              style: TextStyle(
                color: Color(0xFFD80309),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const KategoriScreen();
        break;
      case 2:
        nextScreen = const CartScreen();
        break;
      case 3:
        nextScreen = const HistoryScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
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
        title: const Text(
          'Akun Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === HEADER PROFIL ===
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD80309),
                        width: 2,
                      ),
                      image: _getProfileImage() != null
                          ? DecorationImage(
                              image: _getProfileImage()!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _getProfileImage() == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFFD80309),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              color: Color(0xFFD80309),
                              strokeWidth: 2,
                            ),
                          )
                        else ...[
                          Text(
                            _currentUser?.nama ?? 'Gagal memuat nama',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.email ?? 'Gagal memuat email',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD80309),
                              side: const BorderSide(color: Color(0xFFD80309)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                     EditProfileScreen(user: _currentUser!),
                                ),
                              );
                              if (result == true) {
                                _isLoading = true;
                                setState(() {});
                                _fetchProfilUser();
                              }
                            },
                            child: const Text(
                              'Edit Profil',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // === SECTION 1: AKTIVITAS SAYA ===
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                    child: Text(
                      'Aktivitas Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                    title: const Text(
                      'Pesanan Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.black12,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.star_border_outlined,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                    title: const Text(
                      'Ulasan Saya',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      // Mengarahkan ke halaman Ulasan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UlasanScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // === SECTION 2: PENGATURAN AKUN ===
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                    child: Text(
                      'Pengaturan Akun',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                    title: const Text(
                      'Alamat Pengiriman',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlamatPengirimanScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.black12,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                    title: const Text(
                      'Pusat Bantuan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      // Mengarahkan ke halaman Pusat Bantuan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PusatBantuanScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // === TOMBOL KELUAR ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD80309),
                    side: const BorderSide(
                      color: Color(0xFFD80309),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _prosesLogout(),
                  child: const Text(
                    'KELUAR AKUN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

      // === NAVIGASI BAWAH ===
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFFFFF5F5),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFFD80309),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                );
              }
              return const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFFD80309), size: 26);
              }
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
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Kategori',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFD80309),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text(
                    '$cartCount',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFD80309),
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Keranjang',
              ),
              const NavigationDestination(
                icon: Icon(Icons.history),
                selectedIcon: Icon(Icons.manage_history),
                label: 'Riwayat',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Akun',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
