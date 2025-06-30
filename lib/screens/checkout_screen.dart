// lib/screens/admin/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/screens/new_transaction_screen.dart'; // Untuk akses TransactionCartItem
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
// import 'package:sentra_coffee_frontend/screens/payment_success_screen.dart'; // Nanti untuk navigasi

class CheckoutScreen extends StatefulWidget {
  final List<TransactionCartItem> orderItems;
  final double totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.orderItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
  }

  void _processPayment() async {
    // Fungsi ini akan kita lengkapi nanti untuk menyambung ke backend create.php
    setState(() => _isLoading = true);

    print('Proses pembayaran untuk total: ${_formatRupiah(widget.totalPrice)}');
    // Simulasi
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      // TODO: Navigasi ke PaymentSuccessScreen
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()), (route) => false);
      print('Transaksi Berhasil (Simulasi)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.orderItems.length,
              itemBuilder: (context, index) {
                final item = widget.orderItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.coffee_outlined, size: 40, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.menu.namaMenu, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('single | iced | ${item.size} | full ice', style: TextStyle(color: Colors.grey[600])),
                            Text('x ${item.quantity}', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text(_formatRupiah(item.menu.harga * item.quantity), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            // TODO: Fungsi untuk hapus item
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,-5))]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Price', style: TextStyle(color: Colors.grey)),
                    Text(_formatRupiah(widget.totalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            padding: const EdgeInsets.symmetric(horizontal: 30)
                          ),
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text('Next', style: TextStyle(fontSize: 16)),
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}