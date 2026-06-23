import 'package:flutter/material.dart';
import '../services/order_api_service.dart';
import 'home_screen.dart';
import 'kategori_screen.dart';
import 'cart_screen.dart';
import 'akun_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../providers/cart_provider.dart';
import 'payment_screen.dart';
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final int _selectedIndex = 3; 

  final OrderApiService _apiService = OrderApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _riwayatAsli = []; // Menyimpan data tarikan dari DB Laravel

  // Daftar Filter Status
  final List<String> _filters = ["Semua", "Belum Dibayar", "Diproses", "Dikirim", "Selesai", "Dibatalkan"];
  int _activeFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatPesanan();
  }

  // === FUNGSI SAKTI MENGAMBIL & MENGOLAH DATA RIWAYAT DARI LARAVEL ===
  Future<void> _fetchRiwayatPesanan() async {
    try {
      final response = await _apiService.getOrders();
      
      if (mounted) {
        setState(() {
          // Mapping data JSON dari Laravel agar sesuai dengan struktur UI Flutter kita
          _riwayatAsli = (response.data as List).map((json) {
            String statusApi = json['status'] ?? 'Belum Dibayar';
            Color statusColor = Colors.grey;
            String tombolAksi = 'Lihat Detail';

            // Mengatur Warna & Tombol berdasarkan Status
            if (statusApi.toLowerCase() == 'belum dibayar' || statusApi.toLowerCase() == 'pending' || statusApi.toLowerCase() == 'menunggu pembayaran') {
              statusColor = const Color(0xFFD80309);
              tombolAksi = 'Bayar Sekarang';
              statusApi = 'Belum Dibayar'; // Normalisasi teks
            } else if (statusApi.toLowerCase() == 'menunggu konfirmasi') {
              statusColor = Colors.orangeAccent;
              tombolAksi = 'Lihat Detail';
              statusApi = 'Menunggu Konfirmasi';
            } else if (statusApi.toLowerCase() == 'selesai' || statusApi.toLowerCase() == 'completed') {
              statusColor = Colors.green;
              tombolAksi = 'Beli Lagi';
              statusApi = 'Selesai';
            } else if (statusApi.toLowerCase() == 'dikirim' || statusApi.toLowerCase() == 'shipped') {
              statusColor = Colors.blue;
              tombolAksi = 'Lihat Resi';
              statusApi = 'Dikirim';
            } else if (statusApi.toLowerCase() == 'diproses' || statusApi.toLowerCase() == 'processing') {
              statusColor = Colors.orange;
              tombolAksi = 'Lihat Detail';
              statusApi = 'Diproses';
            } else if (statusApi.toLowerCase() == 'dibatalkan' || statusApi.toLowerCase() == 'cancelled') {
              statusColor = Colors.grey;
              tombolAksi = 'Beli Lagi';
              statusApi = 'Dibatalkan';
            }

            // Mengolah rincian item jadi 1 baris string ("Makaroni, Basreng...")
            List items = json['items'] ?? [];
            String itemString = items.isNotEmpty 
                ? items.map((i) {
                    if (i['product'] != null) return i['product']['nama_produk'] ?? 'Produk';
                    return i['product_name'] ?? i['nama_produk'] ?? 'Produk Lada Bits';
                  }).join(', ')
                : 'Paket Lada Bits';

            String? gambarProduk;
            if (items.isNotEmpty && items[0]['product'] != null && items[0]['product']['gambar'] != null) {
              String img = items[0]['product']['gambar'];
              if (img.isNotEmpty) {
                if (img.startsWith('assets/')) {
                  gambarProduk = img; // Gambar adalah aset lokal, biarkan saja
                } else {
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
                  gambarProduk = img;
                }
              }
            }

            // Mengamankan data tanggal
            String rawDate = json['created_at'] ?? '';
            String formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : 'Hari Ini';

            return {
              "id": json['order_number'] ?? '#LB-${json['id'] ?? 'XXX'}',
              "order_id": json['id'],
              "tanggal": formattedDate,
              "status": statusApi,
              "jml_produk": items.isNotEmpty ? items.length : 1,
              "item": itemString,
              "gambar": gambarProduk,
              "ongkir": json['ongkir'] ?? 0,
              "wilayah_pengiriman": json['wilayah_pengiriman'] ?? 'Lainnya',
              "total": json['total_price'] ?? json['total_harga'] ?? 0,
              "tombol": tombolAksi,
              "color": statusColor
            };
          }).toList();
          
          // Reverse agar pesanan terbaru ada di paling atas
          _riwayatAsli = _riwayatAsli.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal ambil riwayat: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat riwayat pesanan.'), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Widget nextScreen;
    switch (index) {
      case 0: nextScreen = const HomeScreen(); break;
      case 1: nextScreen = const KategoriScreen(); break;
      case 2: nextScreen = const CartScreen(); break;
      case 4: nextScreen = const AkunScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  void _tampilkanResi(Map<String, dynamic> trx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.local_shipping, color: Color(0xFFD80309)),
            SizedBox(width: 8),
            Text('Lacak Pesanan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No. Resi: JNT-${trx['id'].toString().replaceAll('#', '')}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111111))),
            const SizedBox(height: 16),
            const Text('Status Terbaru:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            const Text('Paket sedang dibawa oleh kurir menuju alamat tujuan Kakak. Mohon ditunggu ya! 🛵', style: TextStyle(height: 1.5)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _konfirmasiTerimaPesanan(trx['order_id']); // Panggil fungsi terima pesanan
            },
            child: const Text('PESANAN DITERIMA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Future<void> _konfirmasiTerimaPesanan(int orderId) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.updateOrderStatus(orderId, 'Selesai');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hore! Pesanan telah selesai.'), backgroundColor: Colors.green)
          );
          _fetchRiwayatPesanan(); // Refresh UI dan otomatis pindah tab Selesai
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyelesaikan pesanan.'), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _tampilkanDetail(Map<String, dynamic> trx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 24),
            const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(trx['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: trx['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(trx['status'], style: TextStyle(color: trx['color'], fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Rincian Produk:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(trx['item'], style: const TextStyle(height: 1.5, fontWeight: FontWeight.w500)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ongkos Kirim (${trx['wilayah_pengiriman']})', style: const TextStyle(fontSize: 12)),
                Text('Rp ${trx['ongkir']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Belanja', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp ${trx['total']}', style: const TextStyle(color: Color(0xFFD80309), fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('TUTUP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _prosesTombolAksi(Map<String, dynamic> trx) {
    if (trx['tombol'] == 'Beli Lagi') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan ke keranjang!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
    } else if (trx['tombol'] == 'Lihat Resi') {
      _tampilkanResi(trx);
    } else if (trx['tombol'] == 'Lihat Detail') {
      _tampilkanDetail(trx);
    } else if (trx['tombol'] == 'Bayar Sekarang') {
       Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(order: trx)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // MENGAMBIL DATA KERANJANG ASLI DARI PROVIDER
    final cartCount = context.watch<CartProvider>().cartCount;

    // Terapkan Filter berdasarkan status
    List<Map<String, dynamic>> riwayatTampil = _activeFilterIndex == 0 
        ? _riwayatAsli 
        : _riwayatAsli.where((trx) => trx['status'] == _filters[_activeFilterIndex]).toList();

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
        title: const Text('Riwayat Pembelian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isActive = index == _activeFilterIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeFilterIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF111111) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isActive ? const Color(0xFF111111) : Colors.grey.shade300),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD80309)))
            : riwayatTampil.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Belum ada pesanan yang ${_filters[_activeFilterIndex].toLowerCase()}', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: riwayatTampil.length,
                itemBuilder: (context, index) {
                  final trx = riwayatTampil[index];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trx['id'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF111111))),
                                  const SizedBox(height: 4),
                                  Text(trx['tanggal'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: trx['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  trx['status'],
                                  style: TextStyle(color: trx['color'], fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 65, height: 65,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5F5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: trx['gambar'] != null && trx['gambar'].toString().isNotEmpty
                                      ? (trx['gambar'].toString().startsWith('assets/')
                                          ? Image.asset(
                                              trx['gambar'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, trace) => const Icon(Icons.image_outlined, color: Colors.black26),
                                            )
                                          : Image.network(
                                              trx['gambar'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, trace) => const Icon(Icons.image_outlined, color: Colors.black26),
                                            ))
                                      : const Icon(Icons.image_outlined, color: Colors.black26),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${trx['jml_produk']} Produk', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(
                                      trx['item'],
                                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text(
                                              'Rp ${trx['total']}',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFFD80309)),
                                            ),
                                          ],
                                        ),
                                        OutlinedButton(
                                          onPressed: () => _prosesTombolAksi(trx),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            side: const BorderSide(color: Color(0xFF111111)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Text(
                                            trx['tombol'],
                                            style: const TextStyle(color: Color(0xFF111111), fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Colors.black12),
                        
                        InkWell(
                          onTap: () => _tampilkanDetail(trx),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Text('Lihat Detail', style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: const Color(0xFFFFF5F5), 
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: Color(0xFFD80309), fontSize: 12, fontWeight: FontWeight.bold);
              }
              return const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600);
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