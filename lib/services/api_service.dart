// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/cart.dart'; 


class ApiService {
  // Pastikan ini adalah alamat yang benar untuk lingkungan lo
  // Jika pakai Chrome, bisa http://localhost/ atau http://127.0.0.1/
  final String _baseUrl =
      'http://localhost/SentraCoffee/api/'; // <-- COBA PAKAI 127.0.0.1

  // --- Endpoint untuk Menu ---
  Future<List<Menu>> fetchAllMenu() async {
    // UBAH: Hapus .php dari URL
    final response =
        await http.get(Uri.parse('${_baseUrl}menu/read.php')); // <-- HAPUS .php

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('records') &&
          responseData['records'] is List) {
        List<dynamic> menuJson = responseData['records'];
        return menuJson.map((json) => Menu.fromJson(json)).toList();
      } else {
        throw Exception(
            'Format respons API menu tidak valid: Tidak ada kunci "records".');
      }
    } else {
      throw Exception('Gagal memuat menu. Status Code: ${response.statusCode}');
    }
  }

  // --- Endpoint untuk Registrasi Customer ---
  Future<Map<String, dynamic>> registerUser(
      String nama, String email, String password, String? noHp) async {
    // UBAH: Hapus .php dari URL
    final response = await http.post(
      Uri.parse('${_baseUrl}customer/create.php'), // <-- HAPUS .php
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama': nama,
        'email': email,
        'password': password,
        'no_hp': noHp,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'message': responseData['message']};
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Registrasi gagal.'
      };
    }
  }

  // --- Endpoint untuk Login Customer ---
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    // URL ini sudah tanpa .php, jadi biarkan saja
    final response = await http.post(
      Uri.parse(
          '${_baseUrl}customer/login'), // Endpoint login (tanpa .php karena router)
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseData['message'],
        'customer': Customer.fromJson(responseData),
        'nama': responseData['nama'],
      };
    } else {
      return {
        'success': false,
        'message':
            responseData['message'] ?? 'Login gagal. Cek email dan password.'
      };
    }
  }

  // TODO: Tambahkan method lain untuk orders, dll.
  // --- Endpoint untuk Membuat Pesanan (Transaksi) Baru ---
  Future<Map<String, dynamic>> createOrder({
    required int idCustomer,
    required String paymentMethod,
    required double totalAmount,
    required int pointsEarned, // Poin yang didapat dari transaksi ini
    required List<CartItem> cartItems, // Detail item dari keranjang
    String status = 'Completed', // Default status
    int idStaff = 1, // Asumsi default id_staff=1, ganti jika ada logika staff
  }) async {
    // Siapkan transaction_details dalam format yang diharapkan backend
    List<Map<String, dynamic>> transactionDetails = cartItems.map((item) {
      return {
        'id_menu': item.idMenu, // Asumsi CartItem punya idMenu
        'quantity': item.quantity,
        'subtotal': item.pricePerItem * item.quantity, // Hitung subtotal per item
      };
    }).toList();

    final response = await http.post(
      Uri.parse('${_baseUrl}transaction/create'), // Endpoint create transaksi
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_customer': idCustomer,
        'id_staff': idStaff,
        'payment_method': paymentMethod,
        'total_amount': totalAmount,
        'points_earned': pointsEarned,
        'status': status,
        'transaction_details': transactionDetails,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 201) { // HTTP 201 Created untuk sukses
      return {'success': true, 'message': responseData['message'], 'id_transaction': responseData['id_transaction']};
    } else {
      return {'success': false, 'message': responseData['message'] ?? 'Gagal membuat pesanan.'};
    }
  }
}
