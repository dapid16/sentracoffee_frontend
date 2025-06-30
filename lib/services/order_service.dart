// lib/services/order_service.dart (VERSI FINAL DENGAN PERBAIKAN FILTER)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:sentra_coffee_frontend/models/order.dart';

class OrderService with ChangeNotifier {
  final String _baseUrl =
      'http://localhost/SentraCoffee/api/transaction/read.php'; // Pakai localhost untuk Chrome

  List<Order> _allOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter order berdasarkan status
  List<Order> get onGoingOrders => _allOrders
      .where((order) => order.status.toLowerCase() == 'on going')
      .toList();

  // --- PERBAIKAN DI SINI ---
  List<Order> get historyOrders => _allOrders
      .where((order) => order.status.toLowerCase() == 'completed')
      .toList();

  Future<void> fetchOrders({required String idCustomer}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl?id_customer=$idCustomer');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map && responseData.containsKey('records')) {
          List<dynamic> data = responseData['records'];
          _allOrders = data.map((json) => Order.fromJson(json)).toList();
          debugPrint(
              'Orders fetched successfully: ${_allOrders.length} orders for customer #$idCustomer');
        } else {
          _allOrders = [];
          debugPrint(
              'No order records found for customer #$idCustomer or invalid format.');
        }
      } else {
        _errorMessage = 'Failed to load orders: ${response.statusCode}';
        debugPrint(
            'Failed to load orders: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching orders: $e';
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi addOrder kita biarkan dulu
  Future<bool> addOrder(Map<String, dynamic> orderData) async {
    // ...
    return false;
  }
}
