// lib/screens/order_history_screen.dart (VERSI TANPA "ON GOING")

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/services/order_service.dart';
import 'package:sentra_coffee_frontend/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

// --- PERUBAHAN #1: Hapus `with SingleTickerProviderStateMixin` karena TabController tidak dipakai lagi ---
class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // --- PERUBAHAN #2: Hapus TabController ---
  // late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // --- PERUBAHAN #3: Hapus inisialisasi TabController ---
    // _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final customerId = authService.loggedInCustomer?.idCustomer;

        if (customerId != null) {
          Provider.of<OrderService>(context, listen: false)
              .fetchOrders(idCustomer: customerId.toString());
        }
      }
    });
  }

  // --- PERUBAHAN #4: Hapus dispose untuk TabController ---
  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMM y, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatRupiah(String amount) {
    final number = double.tryParse(amount) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(
      builder: (context, orderService, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              'My Orders', // Atau ganti jadi 'Order History'
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            // --- PERUBAHAN #5: Hapus `bottom` yang berisi TabBar ---
          ),
          // --- PERUBAHAN #6: Ganti TabBarView menjadi tampilan langsung untuk history ---
          body: orderService.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.brown))
              : orderService.errorMessage != null
                  ? Center(child: Text('Error: ${orderService.errorMessage}'))
                  : _buildOrderList(orderService.historyOrders),
        );
      },
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No order history yet!', // Teks disesuaikan
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.idTransaction}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      _formatDate(order.transactionDate),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 20),
                ...order.details.map((detail) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${detail.quantity}x ${detail.namaMenu}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatRupiah(detail.subtotal),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatRupiah(order.totalAmount),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}