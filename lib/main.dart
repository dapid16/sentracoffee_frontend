// lib/main.dart (VERSI PALING FINAL & BERSIH)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/models/loyalty.dart';
import 'package:sentra_coffee_frontend/screens/admin_dashboard_screen.dart';
import 'package:sentra_coffee_frontend/screens/home_screen.dart';
import 'package:sentra_coffee_frontend/screens/landing_screen.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/services/order_service.dart';
// Hapus import admin_login_screen.dart karena sudah tidak dipakai

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => AdminAuthService()),
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
      // --- PERBAIKAN: Hapus properti `routes` karena sudah tidak perlu ---
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final adminAuthService = Provider.of<AdminAuthService>(context);

    if (adminAuthService.isAdminLoggedIn) {
      return const AdminDashboardScreen();
    }
    else if (authService.isLoggedIn) {
      return const HomeScreen();
    }
    else {
      return const LandingScreen();
    }
  }
}