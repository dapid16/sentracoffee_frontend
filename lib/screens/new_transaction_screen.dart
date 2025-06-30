// lib/screens/admin/new_transaction_screen.dart (VERSI UPGRADE DENGAN EDIT)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/screens/product_options_screen.dart';
import 'package:sentra_coffee_frontend/screens/checkout_screen.dart';

// Model ini tetap sama
class TransactionCartItem {
  final Menu menu;
  int quantity;
  String size;
  TransactionCartItem({required this.menu, required this.quantity, required this.size});
}

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({Key? key}) : super(key: key);

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Menu>> _menuFuture;

  final List<TransactionCartItem> _currentOrder = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _menuFuture = _apiService.fetchAllMenu();
  }

  // --- FUNGSI INI KITA UPGRADE UNTUK HANDLE EDIT ---
  void _updateCart(CustomizedOrderItem newItem, {int? editIndex}) {
    setState(() {
      if (editIndex != null) {
        // Mode EDIT: Ganti item di index yang spesifik
        _currentOrder[editIndex].quantity = newItem.quantity;
        _currentOrder[editIndex].size = newItem.size;
      } else {
        // Mode ADD: Cek apakah item yang sama sudah ada
        var existingItemIndex = _currentOrder.indexWhere((item) =>
            item.menu.idMenu == newItem.menu.idMenu && item.size == newItem.size);

        if (existingItemIndex != -1) {
          _currentOrder[existingItemIndex].quantity += newItem.quantity;
        } else {
          _currentOrder.add(TransactionCartItem(
            menu: newItem.menu,
            quantity: newItem.quantity,
            size: newItem.size,
          ));
        }
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _currentOrder) {
      double basePrice = item.menu.harga;
      if (item.size == 'small') basePrice *= 0.8;
      if (item.size == 'large') basePrice *= 1.2;
      total += basePrice * item.quantity;
    }
    setState(() { _totalPrice = total; });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // --- Fungsi baru untuk membuka halaman opsi dalam mode EDIT ---
  void _editItemInOrder(int index) async {
    final result = await Navigator.push<CustomizedOrderItem>(
      context,
      MaterialPageRoute(builder: (context) => ProductOptionsScreen(
        menu: _currentOrder[index].menu,
        initialItem: _currentOrder[index], // Kirim data item yang ada
      )),
    );
    if (result != null) {
      _updateCart(result, editIndex: index); // Panggil _updateCart dengan editIndex
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Transaction'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Menu>>(
              future: _menuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Menu tidak ditemukan.'));
                }
                final menus = snapshot.data!;
                return GridView.builder(
                  // ... (GridView tidak berubah) ...
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return _buildMenuCard(menu);
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Current Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  Expanded(
                    child: _currentOrder.isEmpty
                        ? const Center(child: Text('Keranjang masih kosong.'))
                        // --- LIST KERANJANG SEKARANG BISA DI-KLIK UNTUK EDIT ---
                        : ListView.builder(
                            itemCount: _currentOrder.length,
                            itemBuilder: (context, index) {
                              final item = _currentOrder[index];
                              return ListTile(
                                title: Text('${item.quantity}x ${item.menu.namaMenu}'),
                                subtitle: Text(item.size),
                                onTap: () => _editItemInOrder(index), // Panggil fungsi edit
                              );
                            },
                          ),
                  ),
                  const Divider(height: 24),
                  ElevatedButton(
                    onPressed: _currentOrder.isNotEmpty ? () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(
                        orderItems: _currentOrder,
                        totalPrice: _totalPrice,
                      )));
                    } : null, // Disable tombol jika keranjang kosong
                    child: const Text('Proses Pembayaran'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<CustomizedOrderItem>(
            context,
            MaterialPageRoute(builder: (context) => ProductOptionsScreen(menu: menu)),
          );
          if (result != null) {
            _addItemToOrder(result);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                    child: Icon(Icons.coffee_outlined, size: 50, color: Colors.grey[600])),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(menu.harga), style: TextStyle(color: Colors.brown)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

