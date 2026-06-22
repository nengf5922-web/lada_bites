import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; 
import 'home_screen.dart';
import '../services/api_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Tunggu 3 detik untuk animasi splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    // Cek apakah ada token yang tersimpan
    String? token = await apiClient.storage.read(key: 'auth_token');
    
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Jika sudah login, langsung ke Home Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Jika belum login, ke Login Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan logo di tengah layar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF8F9FA), // Latar belakang putih/abu-abu terang
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spacer agar logo berada sedikit ke atas dari tengah
            const Spacer(flex: 2),
            // Logo Lada Bites
            Image.asset(
              'assets/logo.png',
              width: 350,
              height: 350,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
              },
            ),
            const Spacer(flex: 1),
            // Loading Indicator di bawah
            const CircularProgressIndicator(
              color: Color(0xFFD80309),
              strokeWidth: 4,
            ),
            const SizedBox(height: 50), // Jarak dari bawah layar
          ],
        ),
      ),
    );
  }
}