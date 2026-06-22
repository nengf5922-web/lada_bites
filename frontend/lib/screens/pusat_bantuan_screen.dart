import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PusatBantuanScreen extends StatelessWidget {
  const PusatBantuanScreen({super.key});

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
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Hai! Ada yang bisa kami bantu?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
                  const SizedBox(height: 8),
                  const Text('Temukan jawaban dari pertanyaan yang sering ditanyakan di bawah ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // === FAQ SECTION ===
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Pertanyaan Populer (FAQ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildFaqItem('Berapa lama pesanan saya akan dikirim?', 'Pesanan yang masuk sebelum jam 15.00 akan dikirim pada hari yang sama. Setelah itu, akan dikirim H+1 (kecuali hari libur).'),
                  const Divider(height: 1),
                  _buildFaqItem('Apakah bisa bayar di tempat (COD)?', 'Tentu saja! Lada Bits menyediakan opsi pembayaran di tempat (COD) untuk kurir tertentu yang tersedia di daerahmu.'),
                  const Divider(height: 1),
                  _buildFaqItem('Barang yang saya terima rusak/kurang, bagaimana?', 'Mohon maaf atas ketidaknyamanannya. Silakan hubungi admin kami melalui tombol di bawah ini dengan melampirkan video unboxing sebagai bukti.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // === TOMBOL HUBUNGI ADMIN ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // Warna hijau khas WhatsApp
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat Admin (WhatsApp)', style: TextStyle(fontWeight: FontWeight.w900)),
                  onPressed: () async {
                    final String phoneNumber = "6282115352545"; // Ganti dengan nomor admin Lada Bits
                    final String message = "Halo Admin Lada Bits, saya butuh bantuan.";
                    final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

                    try {
                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka browser atau WhatsApp.')));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      iconColor: const Color(0xFFD80309),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        Text(answer, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
      ],
    );
  }
}