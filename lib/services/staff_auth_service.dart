import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/staff.dart'; // Pastikan path ke model Staff benar

class StaffAuthService with ChangeNotifier {
  Staff? _currentStaff;
  bool _isLoggedIn = false;

  Staff? get currentStaff => _currentStaff;
  bool get isLoggedIn => _isLoggedIn;

  void loginWithStaffData(Staff staff) {
    _currentStaff = staff;
    _isLoggedIn = true;
    notifyListeners(); // Beri tahu UI bahwa state berubah
  }

  void logout() {
    _currentStaff = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}