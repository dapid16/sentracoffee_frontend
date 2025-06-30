// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'dart:typed_data';
import 'package:sentra_coffee_frontend/models/staff.dart';

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

  // Tambahkan fungsi ini di dalam class ApiService
// Hapus atau beri komentar pada fungsi loginUser() dan loginOwner() yang lama

  Future<Map<String, dynamic>> unifiedLogin(
      String email, String password) async {
    final url = Uri.parse(
        'http://localhost/SentraCoffee/api/auth/login.php'); // URL endpoint baru kita

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      // Jika ada error koneksi, kembalikan response error custom
      return {
        'success': false,
        'message': 'Gagal terhubung ke server: $e',
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
        'subtotal':
            item.pricePerItem * item.quantity, // Hitung subtotal per item
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
    if (response.statusCode == 201) {
      // HTTP 201 Created untuk sukses
      return {
        'success': true,
        'message': responseData['message'],
        'id_transaction': responseData['id_transaction']
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 'Gagal membuat pesanan.'
      };
    }
  }

  Future<bool> createMenu(Menu menuData) async {
    final url = Uri.parse('http://localhost/SentraCoffee/api/menu/create.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            menuData.toJson()), // Kita pakai method toJson dari model Menu
      );

      if (response.statusCode == 201) {
        // 201 artinya 'Created'
        print('Menu created successfully: ${response.body}');
        return true;
      } else {
        print(
            'Failed to create menu. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating menu: $e');
      return false;
    }
  }

// Tambahkan fungsi ini di dalam class ApiService

// Fungsi untuk upload gambar dan mendapatkan nama filenya
  Future<String?> uploadImage(Uint8List imageBytes, String filename) async {
    var uri =
        Uri.parse('http://localhost/SentraCoffee/api/menu/upload_image.php');
    var request = http.MultipartRequest('POST', uri);

    // Buat file multipart dari data bytes
    var multipartFile = http.MultipartFile.fromBytes(
      'image', // 'image' harus sama dengan key di `$_FILES['image']` pada PHP
      imageBytes,
      filename: filename,
    );

    request.files.add(multipartFile);

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData[
              'filename']; // Kembalikan nama file baru dari server
        }
      }
      return null;
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<List<Staff>> fetchAllStaff() async {
  final url = Uri.parse('http://localhost/SentraCoffee/api/staff/read.php');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Gunakan helper staffFromJson yang sudah kita buat di model
      return staffFromJson(response.body);
    } else {
      throw Exception('Gagal memuat daftar staff');
    }
  } catch (e) {
    throw Exception('Error fetching staff: $e');
  }
}

// Tambahkan di dalam class ApiService
Future<bool> createStaff({
  required String namaStaff,
  required String email,
  required String password,
  required String role,
  String? noHp,
  required int idOwner,
}) async {
  final url = Uri.parse('http://localhost/SentraCoffee/api/staff/create.php');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama_staff': namaStaff,
        'email': email,
        'password': password,
        'role': role,
        'no_hp': noHp,
        'id_owner': idOwner,
      }),
    );
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  } catch (e) {
    print('Error creating staff: $e');
    return false;
  }
}
}
