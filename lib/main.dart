// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/screens/landing_screen.dart';
import 'package:sentra_coffee_frontend/screens/cart_screen.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/services/order_service.dart'; // <<< Import OrderService

void main() {
  runApp(
    // Gunakan MultiProvider untuk menyediakan beberapa service
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => OrderService()), // <<< Sediakan OrderService
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrderHistoryScreen(userName: 'Alex'), // Pastikan OrderHistoryScreen sudah diimport
      },
    );
  }
}