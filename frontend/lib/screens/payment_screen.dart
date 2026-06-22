import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadBukti() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final response = await _orderApiService.uploadBuktiPembayaran(widget.order['id'], _selectedImage!);
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bukti berhasil diunggah! Pesanan akan diproses.')));
          // Kembali ke history
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengunggah bukti pembayaran.'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                  const Icon(Icons.qr_code_2, size: 200, color: Color(0xFF111111)),
                  const SizedBox(height: 16),
                  const Text('Lada Bits Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Silakan unggah screenshot atau foto bukti transfer Anda.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 16),
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD80309)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.image, color: Color(0xFFD80309)),
                      label: Text(_selectedImage == null ? 'Pilih Gambar Bukti' : 'Ganti Gambar', style: const TextStyle(color: Color(0xFFD80309), fontWeight: FontWeight.bold)),
                      onPressed: _pickImage,
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
                backgroundColor: const Color(0xFFD80309),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _selectedImage == null || _isUploading ? null : _uploadBukti,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('KIRIM BUKTI PEMBAYARAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ),
      ),
    );
  }
}
