// lib/services/order_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:sentra_coffee_frontend/models/order.dart'; // Import model Order

class OrderService with ChangeNotifier {
  // Ganti dengan URL API backend lo yang sebenarnya!
  final String _baseUrl = 'http://192.168.1.100/api/orders.php'; // <<< GANTI DENGAN IP KOMPUTER LO ATAU DOMAIN SERVER LO

  List<Order> _allOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter order berdasarkan status
  List<Order> get onGoingOrders =>
      _allOrders.where((order) => order.status == 'On going').toList();
  List<Order> get historyOrders =>
      _allOrders.where((order) => order.status == 'History').toList();

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beritahu UI kalau loading dimulai

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Asumsi backend mengembalikan array JSON
        List<dynamic> data = json.decode(response.body);
        _allOrders = data.map((json) => Order.fromJson(json)).toList();
        debugPrint('Orders fetched successfully: ${_allOrders.length} orders');
      } else {
        _errorMessage = 'Failed to load orders: ${response.statusCode}';
        debugPrint('Failed to load orders: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error fetching orders: $e';
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Beritahu UI kalau loading selesai
    }
  }

  // Tambahkan juga method untuk Add Order jika nanti diperlukan
  Future<bool> addOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Setelah sukses, mungkin perlu refresh daftar order
        await fetchOrders(); // Ambil ulang semua order
        debugPrint('Order added successfully');
        return true;
      } else {
        _errorMessage = 'Failed to add order: ${response.statusCode} - ${response.body}';
        debugPrint('Failed to add order: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding order: $e';
      debugPrint('Error adding order: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}