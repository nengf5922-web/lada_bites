import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/order_api_service.dart';
import 'history_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final OrderApiService _orderApiService = OrderApiService();
  bool _isUploading = false;

  Future<void> _kirimKeWhatsApp() async {
    setState(() => _isUploading = true);

    try {
      // Ubah status jadi menunggu konfirmasi agar di riwayat berubah
      await _orderApiService.updateOrderStatus(widget.order['id'], 'menunggu konfirmasi');
    } catch (e) {
      debugPrint('Gagal update status otomatis: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }

    // Nomor WA Admin (Bisa diganti nanti sesuai kebutuhan)
    String noAdmin = "6282115352545"; // <-- GANTI DENGAN NOMOR ADMIN LADA BITS
    String orderId = widget.order['id'].toString();
    String total = widget.order['total_harga'].toString();
    
    String pesan = "Halo Admin Lada Bits!\n\nSaya ingin mengirimkan bukti pembayaran QRIS untuk pesanan:\n*No. Order:* #LB-$orderId\n*Total:* Rp $total\n\n[Mohon lampirkan foto struk transfer Anda di sini]";
    
    String url = "https://wa.me/$noAdmin?text=${Uri.encodeComponent(pesan)}";
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka WhatsApp. Pastikan aplikasi terinstall.')));
    }
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
        title: const Text('Pembayaran QRIS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text('Rp ${widget.order['total_harga']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFFD80309))),
                  const Divider(height: 32),
                  const Text('Scan kode QR berikut menggunakan aplikasi e-Wallet atau M-Banking Anda.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 24),
                  
                  // Menampilkan gambar QRIS asli
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/qr.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_2, size: 200, color: Colors.grey),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text('Lada Bits Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  
                  // Peringatan Keamanan Anti-Phishing
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.security, color: Colors.orange, size: 28),
                      title: Text(
                        'Peringatan Keamanan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      subtitle: Text(
                        'Pastikan nama merchant di aplikasi pembayaran Anda adalah LADA BITS OFFICIAL. Jangan transfer jika namanya berbeda!',
                        style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat, color: Colors.green, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Kirim via WhatsApp', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
                        SizedBox(height: 4),
                        Text('Tekan tombol di bawah untuk otomatis membuka WhatsApp Admin.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _isUploading ? null : _kirimKeWhatsApp,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat, color: Colors.white),
                        SizedBox(width: 8),
                        Text('KIRIM BUKTI VIA WHATSAPP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
