import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikon Sukses Animasi (Atau static Icon)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, size: 100, color: Colors.green.shade600),
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'Yey! Pembayaran Berhasil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111111)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pesanan Kakak sudah kami terima dan akan segera diproses. Siap-siap kepedesan ya! ðŸ”¥',
                  style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Tombol Lihat Riwayat
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD80309), // Merah Cabai
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                    },
                    child: const Text('LIHAT RIWAYAT PESANAN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tombol Kembali ke Beranda
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                    },
                    child: const Text('KEMBALI KE BERANDA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}