// lib/services/api_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/staff.dart';


class ApiService {
  // Menggunakan IP Address agar bisa diakses dari Chrome
  final String baseUrl = "http://localhost/SentraCoffee/api";

  // --- Endpoint untuk Menu ---
  Future<List<Menu>> fetchAllMenu() async {
    final response = await http.get(Uri.parse('$baseUrl/menu/read.php'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('records') &&
          responseData['records'] is List) {
        List<dynamic> menuJson = responseData['records'];
        return menuJson.map((json) => Menu.fromJson(json)).toList();
      }
    }
    throw Exception('Gagal memuat menu. Status Code: ${response.statusCode}');
  }

  Future<bool> createMenu(Menu menuData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menuData.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<String?> uploadImage(Uint8List imageBytes, String filename) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/menu/upload_image.php'));
    request.files
        .add(http.MultipartFile.fromBytes('image', imageBytes, filename: filename));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return responseData['filename'];
      }
    }
    return null;
  }
  
  // --- ✅ INI METHOD YANG DITAMBAHKAN ---
  Future<bool> updateMenu(Menu menu) async {
    // URL ke API update di backend kamu
    final url = Uri.parse('$baseUrl/menu/update_menu.php');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        // Kirim data menu dalam format JSON
        body: json.encode(menu.toJson()), 
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Cek jika respon dari backend adalah 'success'
        return responseData['status'] == 'success';
      } else {
        // Jika server merespon dengan error (spt 404, 500)
        print('Server error on updateMenu: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // Jika ada error koneksi atau lainnya
      print('Error connecting to server on updateMenu: $e');
      return false;
    }
  }

  // --- Endpoint untuk Customer ---
  Future<Map<String, dynamic>> registerUser(
      String nama, String email, String password, String? noHp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: json
          .encode({'nama': nama, 'email': email, 'password': password, 'no_hp': noHp}),
    );
    return json.decode(response.body);
  }

  Future<List<Customer>> fetchAllCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customer/read.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('records') && data['records'] is List) {
        return (data['records'] as List)
            .map((json) => Customer.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load customers');
  }

  // --- Endpoint untuk Auth ---
     Future<Map<String, dynamic>> unifiedLogin(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return json.decode(response.body);
  }

  // --- Endpoint untuk Staff ---
  Future<List<Staff>> fetchAllStaff() async {
    final response = await http.get(Uri.parse('$baseUrl/staff/read.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('records') && data['records'] is List) {
        return (data['records'] as List)
            .map((json) => Staff.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load staff');
  }

  Future<bool> createStaff({
    required String namaStaff,
    required String email,
    required String password,
    required String role,
    String? noHp,
    required int idOwner,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/create.php'),
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
    return response.statusCode == 201;
  }

  // --- Endpoint untuk Transaksi (Kasir/Admin) ---
   Future<bool> createTransaction({
    required int customerId,
    required int staffId,
    required String paymentMethod,
    required double totalAmount,
    required List<TransactionCartItem> items, // <<< Tipe ini didapat dari menu.dart
    int? pointsUsed,
  }) async {
    // Ubah List<TransactionCartItem> menjadi format JSON yang bisa dikirim
    List<Map<String, dynamic>> itemsJson = items.map((item) {
      return {
        'id_menu': item.menu.idMenu,
        'quantity': item.quantity,
        'subtotal': item.menu.harga * item.quantity,
      };
    }).toList();

    Map<String, dynamic> requestBody = {
      'id_customer': customerId,
      'id_staff': staffId,
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'details': itemsJson,
    };
    
    if (pointsUsed != null) {
      requestBody['points_used'] = pointsUsed;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/transaction/create.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create transaction: ${response.body}');
      return false;
    }
  }
  
  Future<bool> deleteMenu(int idMenu) async {
    final url = Uri.parse('$baseUrl/menu/delete.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        // Kirim ID dalam format JSON di body
        body: json.encode({'id_menu': idMenu}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print('Server error on deleteMenu: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error connecting to server on deleteMenu: $e');
      return false;
    }
  }

    Future<Customer?> fetchOneCustomer(int customerId) async {
    // Ganti 'read_one.php' menjadi 'read_single.php' agar sesuai dengan file-mu
    final response = await http.get(Uri.parse('$baseUrl/customer/read_single.php?id=$customerId'));
    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    }
    return null;
  }
}