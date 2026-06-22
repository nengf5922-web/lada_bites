import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Tambahan untuk kIsWeb
import 'package:google_fonts/google_fonts.dart'; // 1. Tambahan Import Google Fonts
import 'package:provider/provider.dart'; // Tambahan Import Provider
import 'providers/cart_provider.dart'; // Tambahan Import Cart Provider
import 'screens/splash_screen.dart'; // Menambahkan jalur ke file splash screen

void main() {
  runApp(
    // === KODE SAKTI: Membungkus seluruh aplikasi dengan Provider ===
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const LadaBitsApp(),
    ),
  );
}

class LadaBitsApp extends StatelessWidget {
  const LadaBitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lada Bits',
      debugShowCheckedModeBanner:
          false, // Menghilangkan pita "DEBUG" di pojok kanan atas

      theme: ThemeData(
        // Ubah seedColor menjadi merah
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD80309)),
        useMaterial3: true,

        // 2. KODE SAKTI: Mengubah seluruh teks aplikasi menjadi font Poppins (Kecuali Web untuk menghindari bug CanvasKit)
        textTheme: kIsWeb ? null : GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),

      // Arahkan halaman pertama langsung ke Splash Screen
      home: const SplashScreen(),
    );
  }
}