import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- Import Provider
import '../providers/cart_provider.dart'; // <--- Import Cart Provider
import 'home_screen.dart';
import 'kategori_screen.dart';
import 'history_screen.dart';
import 'akun_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final int _selectedIndex = 2; // Index Keranjang Aktif

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Widget nextScreen;
    switch (index) {
      case 0: nextScreen = const HomeScreen(); break;
      case 1: nextScreen = const KategoriScreen(); break;
      case 3: nextScreen = const HistoryScreen(); break; 
      case 4: nextScreen = const AkunScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    // === MENGAMBIL DATA KERANJANG DARI GLOBAL STATE ===
    final cart = context.watch<CartProvider>();
    final keranjang = cart.items;

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
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
        title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),

      body: keranjang.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5), 
                      shape: BoxShape.circle, 
                      boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 10)]
                    ),
                    child: const Center(child: Icon(Icons.shopping_cart_outlined, size: 50, color: Color(0xFFD80309))),
                  ),
                  const SizedBox(height: 24),
                  const Text('Keranjangmu masih kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                  const SizedBox(height: 8),
                  const Text('Yuk cari camilan Lada Bits favoritmu!', style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            )
          : Column(
              children: [
                // PANEL BAR "PILIH SEMUA" 
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: cart.isSemuaTerpilih,
                        activeColor: const Color(0xFFD80309),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) => cart.togglePilihSemua(value ?? false),
                      ),
                      const Text(
                        'Pilih Semua',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111111)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // LIST PRODUK KERANJANG
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: keranjang.length,
                    itemBuilder: (context, index) {
                      final item = keranjang[index];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          children: [
                            // CEKLIS PER PRODUK
                            Checkbox(
                              value: item['terpilih'],
                              activeColor: const Color(0xFFD80309),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (value) => cart.toggleTerpilih(index, value ?? false),
                            ),
                            
                            // GAMBAR PRODUK
                            Container(
                              width: 70, height: 70,
                              decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (item['gambar'] != null && item['gambar'].toString().isNotEmpty)
                                  ? Image.network(
                                      item['gambar'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.black12, size: 30),
                                    )
                                  : const Icon(Icons.image_outlined, color: Colors.black12, size: 30),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // KONTEN INFO & NAMA
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF111111)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('Rp ${item['harga']}', style: const TextStyle(color: Color(0xFFD80309), fontWeight: FontWeight.bold, fontSize: 13)), 
                                ],
                              ),
                            ),
                            
                            // JUMLAH QUANTITY
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                                  onPressed: () => cart.ubahJumlah(index, -1),
                                ),
                                Text('${item['jumlah']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF111111), size: 22), 
                                  onPressed: () => cart.ubahJumlah(index, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

      // BOTTOM BAR PEMBAYARAN
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Belanja', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Rp ${cart.totalBelanja}', style: const TextStyle(color: Color(0xFFD80309), fontSize: 20, fontWeight: FontWeight.w900)), 
                ],
              ),
             ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: !cart.isAdaYangDipilih ? null : () {
                  // FILTER SAKTI: Hanya mengambil list produk yang diberi centang!
                  List<Map<String, dynamic>> produkChecked = keranjang
                      .where((item) => item['terpilih'] == true)
                      .map((item) => {
                            "id": item['id'], // WAJIB DIKIRIM!
                            "nama": item['nama'],
                            "harga": item['harga'],
                            "jumlah": item['jumlah'],
                            "gambar": item['gambar'], // KIRIM GAMBAR JUGA
                          })
                      .toList();

                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(produkDipilih: produkChecked),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: !cart.isAdaYangDipilih ? null : const LinearGradient(colors: [Color(0xFFD80309), Color(0xFFF73E3E)]),
                    color: !cart.isAdaYangDipilih ? Colors.grey.shade300 : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('CHECKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // === BOTTOM NAVIGATION BAR ===
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
                  isLabelVisible: cart.cartCount > 0, 
                  label: Text('${cart.cartCount}', style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFFD80309),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cart.cartCount > 0,
                  label: Text('${cart.cartCount}', style: const TextStyle(color: Colors.white)),
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