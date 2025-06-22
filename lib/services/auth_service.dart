// lib/services/auth_service.dart

import 'dart:convert'; // Untuk mengelola JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:sentra_coffee_frontend/models/customer.dart'; // Import model Customer
import 'package:sentra_coffee_frontend/services/api_service.dart'; // Import ApiService

class AuthService extends ChangeNotifier {
  Customer? _loggedInCustomer; // Data customer yang sedang login

  Customer? get loggedInCustomer => _loggedInCustomer;
  bool get isLoggedIn => _loggedInCustomer != null; // Status login

  // Constructor: Inisialisasi service dan cek status login saat pertama kali dibuat
  AuthService() {
    _loadUserSession();
  }

  // Metode untuk memuat sesi user dari Shared Preferences
  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final customerJson =
        prefs.getString('loggedInCustomer'); // Ambil data customer JSON

    if (customerJson != null) {
      // Jika ada data, parse dan set sebagai customer yang login
      _loggedInCustomer = Customer.fromJson(json.decode(customerJson));
      notifyListeners(); // Beritahu listener bahwa status berubah
    }
  }

  // Metode untuk proses login
  Future<bool> login(String email, String password) async {
    try {
      final apiService = ApiService(); // Buat instance ApiService
      final response = await apiService.loginUser(email, password);

      if (response['success'] == true) {
        // Login sukses
        _loggedInCustomer = response['customer']; // Simpan objek Customer
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'loggedInCustomer',
            json.encode(
                _loggedInCustomer!.toJson())); // Simpan ke Shared Preferences
        print(response['nama']);
        notifyListeners(); // Beritahu listener bahwa status berubah
        return true;
      } else {
        // Login gagal
        _loggedInCustomer = null;
        notifyListeners();
        print('Login Gagal: ${response['message']}');
        return false;
      }
    } catch (e) {
      // Tangani error koneksi atau error lainnya
      _loggedInCustomer = null;
      notifyListeners();
      print('Error saat login: $e');
      return false;
    }
  }

  // Metode untuk proses logout
  Future<void> logout() async {
    _loggedInCustomer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInCustomer'); // Hapus dari Shared Preferences
    notifyListeners(); // Beritahu listener bahwa status berubah
    print('Logout berhasil.');
  }

  // Metode untuk proses registrasi (AuthService hanya memicu, ApiService yang eksekusi)
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
