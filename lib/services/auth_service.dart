// lib/services/auth_service.dart (VERSI SUPER LOGIN)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AuthService extends ChangeNotifier {
  Customer? _loggedInCustomer;

  Customer? get loggedInCustomer => _loggedInCustomer;
  bool get isLoggedIn => _loggedInCustomer != null;

  AuthService() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final customerJson = prefs.getString('loggedInCustomer');

    if (customerJson != null) {
      _loggedInCustomer = Customer.fromJson(json.decode(customerJson));
      notifyListeners();
    }
  }

  // --- FUNGSI LOGIN LAMA KITA GANTI DENGAN INI ---
  // Fungsi ini tidak lagi memanggil API, hanya menerima data dan menyimpan state.
  Future<void> loginWithCustomerData(Customer customerData) async {
    _loggedInCustomer = customerData;
    final prefs = await SharedPreferences.getInstance();
    // Simpan data customer ke SharedPreferences
    await prefs.setString(
        'loggedInCustomer', json.encode(_loggedInCustomer!.toJson()));
    
    // Beri tahu seluruh aplikasi bahwa customer sudah login
    notifyListeners();
    debugPrint('AuthService: Customer ${customerData.nama} has been set as logged in.');
  }
  // --- AKHIR DARI PERUBAHAN ---


  Future<void> logout() async {
    _loggedInCustomer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInCustomer');
    notifyListeners();
    print('Logout berhasil.');
  }

  // Fungsi register tidak perlu diubah, logikanya sudah benar.
  Future<String> register(
      String nama, String email, String password, String? noHp) async {
    try {
      final apiService = ApiService();
      final response =
          await apiService.registerUser(nama, email, password, noHp);

      if (response['success'] == true) {
        return 'Registrasi Berhasil: ${response['message']}';
      } else {
        return 'Registrasi Gagal: ${response['message']}';
      }
    } catch (e) {
      return 'Error Registrasi: $e';
    }
  }
}