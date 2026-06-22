import 'package:flutter/material.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9ECEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD80309), // Merah Cabai
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CS Contact Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD80309), Color(0xFF990000)]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, size: 50, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Butuh Bantuan Langsung?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Tim CS Lada Bits siap membantu Kakak 24/7.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat, size: 16, color: Color(0xFFD80309)),
                          label: const Text('Chat Sekarang', style: TextStyle(color: Color(0xFFD80309), fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(120, 35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pertanyaan Populer (FAQ)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF111111))),
            const SizedBox(height: 12),
            
            // FAQ Accordion
            _buildFAQItem('Berapa lama estimasi pengiriman?', 'Pengiriman standar memakan waktu 2-3 hari kerja tergantung lokasi tujuan Kakak.'),
            _buildFAQItem('Apakah camilan Lada Bits aman untuk lambung?', 'Kami memiliki varian "Lambung Rendah" yang diformulasikan khusus dengan tingkat kepedasan yang aman untuk dinikmati!'),
            _buildFAQItem('Bagaimana cara melacak pesanan saya?', 'Kakak bisa pergi ke menu Akun > Riwayat Pesanan, lalu klik tombol "Lihat Resi" pada pesanan yang sedang dikirim.'),
            _buildFAQItem('Apakah bisa bayar di tempat (COD)?', 'Saat ini kami mendukung pembayaran COD untuk beberapa wilayah tertentu. Silakan cek saat checkout ya!'),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String pertanyaan, String jawaban) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent), // Menghilangkan garis pembatas bawaan
        child: ExpansionTile(
          iconColor: const Color(0xFFD80309),
          collapsedIconColor: Colors.grey,
          title: Text(pertanyaan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111111))),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(jawaban, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}