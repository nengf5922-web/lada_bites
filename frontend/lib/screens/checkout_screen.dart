import 'package:flutter/material.dart';
import '../services/shipping_api_service.dart';
import '../services/user_api_service.dart';
import '../services/order_api_service.dart';
import 'payment_screen.dart'; 

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? produkDipilih; 

  const CheckoutScreen({super.key, this.produkDipilih});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodePembayaran = 'QRIS';
  bool _isLoading = false;

  String _namaPenerima = 'Memuat...';
  String _noHp = 'Memuat...';
  String _alamatLengkap = 'Memuat...';

  final UserApiService _userApiService = UserApiService();
  final OrderApiService _apiService = OrderApiService();
  final ShippingApiService _shippingApiService = ShippingApiService();

  List<Map<String, dynamic>> _listProduk = [];
  int _totalHargaKeseluruhan = 0;

  List<dynamic> _ongkirList = [];
  String? _selectedWilayah;
  int _ongkirTarif = 0;

  @override
  void initState() {
    super.initState();
    if (widget.produkDipilih != null && widget.produkDipilih!.isNotEmpty) {
      _listProduk = List.from(widget.produkDipilih!);
    } else {
      _listProduk = [];
    }
    _hitungTotalHarga();
    _fetchProfilUser();
    _fetchShippingRates();
  }

  Future<void> _fetchProfilUser() async {
    try {
      final response = await _userApiService.getUserProfile();
      if (mounted) {
        setState(() {
          final data = response.data['data'] ?? response.data;
          _namaPenerima = data['name'] ?? 'Penerima';
          _noHp = data['phone'] ?? '081234567890';
          _alamatLengkap = data['address'] ?? 'Alamat belum diatur';
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
      if (mounted) {
        setState(() {
          _namaPenerima = 'Guest';
          _noHp = '-';
          _alamatLengkap = 'Gagal memuat alamat';
        });
      }
    }
  }

  Future<void> _fetchShippingRates() async {
    try {
      final response = await _shippingApiService.getShippingRates();
      if (mounted) {
        setState(() {
          _ongkirList = response.data;
          if (_ongkirList.isNotEmpty) {
            _selectedWilayah = _ongkirList[0]['wilayah'];
            _ongkirTarif = int.tryParse(_ongkirList[0]['tarif'].toString()) ?? 0;
          }
          _hitungTotalHarga();
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat ongkir: $e');
    }
  }

  void _hitungTotalHarga() {
    int total = 0;
    for (var produk in _listProduk) {
      total += (produk['harga'] as int) * (produk['jumlah'] as int);
    }
    setState(() {
      _totalHargaProduk = total;
      _totalHargaKeseluruhan = _totalHargaProduk + _ongkirTarif;
    });
  }

  Future<void> _kirimPesananKeLaravel() async {
    setState(() => _isLoading = true);

    Map<String, dynamic> payloadPesanan = {
      'nama_penerima': _namaPenerima,
      'no_hp': _noHp,
      'alamat_lengkap': _alamatLengkap,
      'metode_pembayaran': _metodePembayaran,
      'wilayah_pengiriman': _selectedWilayah ?? 'Lainnya',
      'ongkir': _ongkirTarif,
      'total_harga': _totalHargaKeseluruhan,
      'items': _listProduk.map((item) => {
        'product_id': item['id'],
        'nama_produk': item['nama'],
        'harga_satuan': item['harga'],
        'jumlah': item['jumlah'],
        'subtotal': (item['harga'] as int) * (item['jumlah'] as int),
      }).toList(),
    };

    try {
      final response = await _apiService.createOrder(payloadPesanan);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          if (_metodePembayaran == 'QRIS') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentScreen(order: response.data['order'])));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
          }
        }
      }
    } on DioException catch (e) {
      String pesanError = 'Waduh, Gagal memproses pesanan ke server.';
      if (e.response != null && e.response?.data['message'] != null) {
        pesanError = e.response?.data['message'];
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesanError), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _tampilkanFormUbahAlamat() {
    final namaController = TextEditingController(text: _namaPenerima);
    final noHpController = TextEditingController(text: _noHp);
    final alamatController = TextEditingController(text: _alamatLengkap);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 16),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                const Text('Ubah Alamat Pengiriman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                const SizedBox(height: 24),
                const Text('Nama Penerima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: namaController, decoration: _buildInputDecoration('Contoh: Budi Santoso')),
                const SizedBox(height: 16),
                const Text('Nomor Handphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: noHpController, keyboardType: TextInputType.phone, decoration: _buildInputDecoration('Contoh: 081234567890')),
                const SizedBox(height: 16),
                const Text('Alamat Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextField(controller: alamatController, maxLines: 3, decoration: _buildInputDecoration('Jalan, RT/RW, Kecamatan, Kota...')),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD80309), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (namaController.text.isEmpty || noHpController.text.isEmpty || alamatController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua kolom alamat ya!'), backgroundColor: Colors.red));
                        return;
                      }
                      setState(() {
                        _namaPenerima = namaController.text;
                        _noHp = noHpController.text;
                        _alamatLengkap = alamatController.text;
                      });
                      Navigator.pop(context); 
                    },
                    child: const Text('SIMPAN ALAMAT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD80309))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFD80309), Color(0xFFF73E3E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      TextButton(onPressed: _tampilkanFormUbahAlamat, child: const Text('Ubah', style: TextStyle(color: Color(0xFFD80309), fontWeight: FontWeight.bold))),
                    ],
                  ),
                  Text('$_namaPenerima ($_noHp)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_alamatLengkap, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _listProduk.length,
                    itemBuilder: (context, index) {
                      final item = _listProduk[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(10)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: (item['gambar'] != null && item['gambar'].toString().isNotEmpty)
                                  ? Image.network(
                                      item['gambar'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_fire_department, color: Color(0xFFD80309)),
                                    )
                                  : const Icon(Icons.local_fire_department, color: Color(0xFFD80309)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('${item['jumlah']} x Rp ${item['harga']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('Rp ${item['harga'] * item['jumlah']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Opsi Pengiriman', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 12),
                  const Text('Pilih Wilayah / Daerah Pengiriman:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (_ongkirList.isEmpty)
                    const Text('Memuat opsi pengiriman...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedWilayah,
                          items: _ongkirList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['wilayah'],
                              child: Text(item['wilayah']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedWilayah = val;
                              final selectedItem = _ongkirList.firstWhere((element) => element['wilayah'] == val);
                              _ongkirTarif = int.tryParse(selectedItem['tarif'].toString()) ?? 0;
                              _hitungTotalHarga();
                            });
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ongkos Kirim', style: TextStyle(color: Colors.black54)),
                      Text('Rp $_ongkirTarif', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildPaymentOption('QRIS', Icons.qr_code_scanner),
                  _buildPaymentOption('Bayar di Tempat (COD)', Icons.delivery_dining),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))], borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Rp $_totalHargaKeseluruhan', style: const TextStyle(color: Color(0xFFD80309), fontSize: 22, fontWeight: FontWeight.w900)), 
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _kirimPesananKeLaravel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD80309), Color(0xFFF73E3E)]), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CHECKOUT SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    return RadioListTile<String>(
      title: Row(
        children: [Icon(icon, color: const Color(0xFF111111), size: 20), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))],
      ),
      value: title,
      groupValue: _metodePembayaran,
      activeColor: const Color(0xFFD80309),
      contentPadding: EdgeInsets.zero,
      onChanged: (String? value) { setState(() { _metodePembayaran = value!; }); },
    );
  }
}