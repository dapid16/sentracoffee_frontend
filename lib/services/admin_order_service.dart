// lib/services/admin_order_service.dart

import 'package:flutter/foundation.dart';
import 'package:sentra_coffee_frontend/models/admin_order.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AdminOrderService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<AdminOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AdminOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    // Notify listeners di awal agar UI bisa menampilkan loading indicator
    notifyListeners();

    try {
      _orders = await _apiService.fetchAllTransactions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}