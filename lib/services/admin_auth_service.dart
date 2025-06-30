// lib/services/admin_auth_service.dart (VERSI SUPER LOGIN)

import 'package:flutter/foundation.dart';
import 'package:sentra_coffee_frontend/models/owner.dart';
// ApiService tidak perlu di-import lagi di sini

class AdminAuthService with ChangeNotifier {
  Owner? _currentOwner;
  // ApiService tidak dibutuhkan lagi di sini

  Owner? get currentOwner => _currentOwner;
  bool get isAdminLoggedIn => _currentOwner != null;

  // --- FUNGSI LOGIN LAMA KITA GANTI DENGAN INI ---
  // Fungsi ini tidak memanggil API, hanya menerima data Owner dan menyimpan state.
  void loginWithOwnerData(Owner ownerData) {
    _currentOwner = ownerData;
    notifyListeners(); // Beri tahu UI bahwa admin sudah login
    debugPrint('AdminAuthService: Owner ${ownerData.namaOwner} has been set as logged in.');
  }
  // --- AKHIR DARI PERUBAHAN ---

  void logout() {
    _currentOwner = null;
    notifyListeners(); // Beri tahu UI bahwa admin sudah logout
    debugPrint('Admin has logged out.');
  }
}