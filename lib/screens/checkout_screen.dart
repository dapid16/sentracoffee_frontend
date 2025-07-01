// lib/screens/checkout_screen.dart (REVISI NAVIGASI KE PAYMENT SCREEN)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/screens/payment_admin_screen.dart'; // <<< IMPORT HALAMAN PAYMENT
import 'package:sentra_coffee_frontend/screens/product_options_screen.dart';

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
  late List<TransactionCartItem> _editableOrderItems;
  late double _currentTotalPrice;
  // bool _isLoading tidak kita perlukan lagi di sini

  @override
  void initState() {
    super.initState();
    _editableOrderItems = List.from(widget.orderItems);
    _currentTotalPrice = widget.totalPrice;
  }
  
  void _handleDeleteItem(int index) {
    setState(() {
      _editableOrderItems.removeAt(index);
      _recalculateTotal();
    });

    if (_editableOrderItems.isEmpty) {
      Navigator.pop(context, _editableOrderItems);
    }
  }

  void _handleEditItem(int index) async {
    final itemToEdit = _editableOrderItems[index];

    final result = await Navigator.push<CustomizedOrderItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductOptionsScreen(
          menu: itemToEdit.menu,
          initialItem: itemToEdit,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _editableOrderItems[index] = TransactionCartItem(
          menu: result.menu,
          quantity: result.quantity,
          size: result.size,
          ristretto: result.ristretto,
          servingStyle: result.servingStyle,
        );
        _recalculateTotal();
      });
    }
  }

  void _recalculateTotal() {
    double total = 0;
    for (var item in _editableOrderItems) {
      double basePrice = item.menu.harga;
      // Logika harga size
       if (item.size == 'small') basePrice *= 0.8;
       if (item.size == 'large') basePrice *= 1.2;
      total += basePrice * item.quantity;
    }
    setState(() {
      _currentTotalPrice = total;
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
  }

  // Fungsi _processPayment dihapus dari sini karena logikanya pindah ke PaymentScreen

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _editableOrderItems);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, _editableOrderItems);
            },
          ),
          title: const Text('Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _editableOrderItems.length,
                itemBuilder: (context, index) {
                  final item = _editableOrderItems[index];
                  // Kita gunakan Dismissible untuk fitur geser-hapus
                  return Dismissible(
                    key: ValueKey(item), // Kunci unik
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _handleDeleteItem(index);
                    },
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.delete, color: Colors.white)],
                      ),
                    ),
                    child: _buildCartItem(item, index),
                  );
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // Di dalam file checkout_screen.dart

Widget _buildCartItem(TransactionCartItem item, int index) {
  // --- Definisikan base URL untuk folder gambar kamu ---
  // Pastikan ini sesuai dengan struktur folder di XAMPP
  final String imageBaseUrl = "http://localhost/SentraCoffee/uploads/";

  // Gabungkan baseUrl dengan nama file dari database
  final String? imageUrl = (item.menu.image != null && item.menu.image!.isNotEmpty)
      ? imageBaseUrl + item.menu.image!
      : null;

  String details = '${item.ristretto} | iced | ${item.size} | full ice';
  double itemPrice = item.menu.harga;
  if (item.size == 'small') itemPrice *= 0.8;
  if (item.size == 'large') itemPrice *= 1.2;

  return Card(
    elevation: 0,
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 4.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () {
        _handleEditItem(index);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // --- Tampilkan gambar dari URL yang sudah benar ---
              child: (imageUrl != null)
                  ? Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Tampilan jika gambar gagal di-load
                        return Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image));
                      },
                    )
                  : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.coffee)), // Tampilan jika tidak ada gambar
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.menu.namaMenu, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(details, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text('x ${item.quantity}', style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            ),
            Text(_formatRupiah(itemPrice * item.quantity), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBottomBar() {
    return Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Price', style: TextStyle(color: Colors.grey)),
              Text(_formatRupiah(_currentTotalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              // --- PERUBAHAN UTAMA DI SINI ---
              onPressed: () {
                // Pindah ke PaymentScreen sambil bawa data keranjang terbaru
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => PaymentAdminScreen(
                    orderItems: _editableOrderItems, 
                    totalPrice: _currentTotalPrice
                  ),
                ));
              },
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
    );
  }
}