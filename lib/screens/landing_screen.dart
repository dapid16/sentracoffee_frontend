// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import untuk menggunakan Timer

// Import halaman login yang akan dituju
import 'package:sentra_coffee_frontend/screens/login_screen.dart'; // Sesuaikan path jika berbeda

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk navigasi setelah beberapa detik
    _navigateToLogin();
  }

  void _navigateToLogin() {
    // Memberikan delay selama 3 detik (sesuaikan durasi sesuai keinginan)
    Future.delayed(const Duration(seconds: 3), () {
      // Menggunakan Navigator.pushReplacement untuk mengganti halaman saat ini
      // sehingga user tidak bisa kembali ke splash screen dengan tombol back
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Opsional: Untuk membuat status bar transparan agar background image terlihat penuh
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // Warna status bar transparan
      statusBarIconBrightness:
          Brightness.light, // Warna ikon status bar (untuk mode gelap)
    ));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Lapis 1: background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_landing.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Lapis 2: semi‐transparent overlay
          Container(
            color:
                Colors.black.withOpacity(0.55), // Meningkatkan opasitas sedikit
          ),

          // Lapis 3: Konten utama (Logo + Judul)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logosentra.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Coffee & Community',
                    style: TextStyle(
                      fontFamily:
                          'Montserrat', // Asumsi: pakai font standar atau font lain
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 80),
                  Text(
                    'Sentra Coffee',
                    style: TextStyle(
                      fontFamily: 'ReenieBeanie',
                      fontSize: 60,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Tombol yang tadi ada di sini sekarang kita hapus, karena otomatis
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
