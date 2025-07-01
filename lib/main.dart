// lib/main.dart (DENGAN LOGIKA STAFF)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/models/loyalty.dart';
import 'package:sentra_coffee_frontend/screens/admin_dashboard_screen.dart'; // <<< PASTIKAN PATH INI BENAR
import 'package:sentra_coffee_frontend/screens/staff_dashboard_screen.dart'; // <<< IMPORT HALAMAN STAFF
import 'package:sentra_coffee_frontend/screens/home_screen.dart';
import 'package:sentra_coffee_frontend/screens/landing_screen.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/services/staff_auth_service.dart'; // <<< IMPORT SERVICE STAFF
import 'package:sentra_coffee_frontend/services/order_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => AdminAuthService()),
        // --- ✅ TAMBAHKAN PROVIDER UNTUK STAFF ---
        ChangeNotifierProvider(create: (context) => StaffAuthService()),
        // -----------------------------------------
        ChangeNotifierProvider(create: (context) => OrderService()),
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => LoyaltyService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentra Coffee App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final adminAuthService = Provider.of<AdminAuthService>(context);
    // --- ✅ AMBIL SERVICE STAFF ---
    final staffAuthService = Provider.of<StaffAuthService>(context);

    // --- ✅ PERBARUI LOGIKA PENGECEKAN ---
    // Urutan pengecekan penting: Admin -> Staff -> Customer
    if (adminAuthService.isAdminLoggedIn) {
      return const AdminDashboardScreen();
    }
    // Cek jika ada staff yang login
    else if (staffAuthService.isLoggedIn) {
      return const StaffDashboardScreen();
    }
    // Baru cek customer
    else if (authService.isLoggedIn) {
      return const HomeScreen();
    }
    // Jika tidak ada yang login sama sekali
    else {
      return const LandingScreen();
    }
  }
}