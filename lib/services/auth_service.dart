// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AuthService with ChangeNotifier {
  // --- PERBAIKAN #1: Deklarasikan ApiService di sini ---
  final ApiService _apiService = ApiService();

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

  Future<void> loginWithCustomerData(Customer customerData) async {
    _loggedInCustomer = customerData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'loggedInCustomer', json.encode(_loggedInCustomer!.toJson()));

    notifyListeners();
    debugPrint(
        'AuthService: Customer ${customerData.nama} has been set as logged in.');
  }

  Future<void> logout() async {
    _loggedInCustomer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInCustomer');
    notifyListeners();
    print('Logout berhasil.');
  }

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

  // --- PERBAIKAN #2: Perbaiki fungsi refresh ---
  Future<void> refreshLoggedInCustomerData() async {
    if (isLoggedIn) {
      // Panggil fungsi dari _apiService yang sudah dideklarasikan di atas
      final updatedCustomer =
          await _apiService.fetchOneCustomer(loggedInCustomer!.idCustomer);

      // Print #1: Cek data poin dari objek yang baru di-fetch
      print(
          "---[AuthService] Updated customer object points: ${updatedCustomer?.points}");

      if (updatedCustomer != null) {
        // Assign ke variabel private _loggedInCustomer, bukan getter-nya
        _loggedInCustomer = updatedCustomer;

        // Simpan juga data terbaru ke SharedPreferences agar sesi tetap update
        final prefs = await SharedPreferences.getInstance();

        // Siapkan data JSON yang akan disimpan
        final jsonToSave = json.encode(_loggedInCustomer!.toJson());

        // Print #2: Cek data JSON yang akan disimpan ke HP
        print(
            "---[AuthService] JSON to be saved in SharedPreferences: $jsonToSave");

        await prefs.setString('loggedInCustomer', jsonToSave);

        // Beri tahu UI untuk update tampilan
        notifyListeners();
      }
    }
  }
}
