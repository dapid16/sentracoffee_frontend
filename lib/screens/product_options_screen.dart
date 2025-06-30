// lib/screens/admin/product_options_screen.dart (VERSI UPGRADE DENGAN EDIT)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/screens/new_transaction_screen.dart'; // Import TransactionCartItem

// Class ini kita pindahkan ke new_transaction_screen.dart agar bisa diakses kedua file
// Tapi untuk sementara kita biarkan di sini juga tidak apa-apa
class CustomizedOrderItem {
  final Menu menu;
  final int quantity;
  final String size;

  CustomizedOrderItem({
    required this.menu,
    required this.quantity,
    required this.size,
  });
}


class ProductOptionsScreen extends StatefulWidget {
  final Menu menu;
  // --- PERUBAHAN #1: Tambahkan parameter opsional untuk item yang mau diedit ---
  final TransactionCartItem? initialItem;

  const ProductOptionsScreen({
    Key? key,
    required this.menu,
    this.initialItem, // Jadikan opsional
  }) : super(key: key);

  @override
  State<ProductOptionsScreen> createState() => _ProductOptionsScreenState();
}

class _ProductOptionsScreenState extends State<ProductOptionsScreen> {
  // State untuk menyimpan pilihan user
  int _quantity = 1;
  List<bool> _sizeSelection = [false, true, false]; // Default: Medium
  late double _totalPrice;

  @override
  void initState() {
    super.initState();
    // --- PERUBAHAN #2: Cek apakah ini mode EDIT atau ADD ---
    if (widget.initialItem != null) {
      // Jika mode EDIT, isi state dengan data yang sudah ada
      _quantity = widget.initialItem!.quantity;
      // Set pilihan ukuran berdasarkan data yang ada
      if (widget.initialItem!.size == 'small') {
        _sizeSelection = [true, false, false];
      } else if (widget.initialItem!.size == 'large') {
        _sizeSelection = [false, false, true];
      } else {
        _sizeSelection = [false, true, false];
      }
    }
    _calculatePrice();
  }

  void _calculatePrice() {
    double basePrice = widget.menu.harga;
    double sizeMultiplier = 1.0;
    if (_sizeSelection[0]) { // Small
      sizeMultiplier = 0.8;
    } else if (_sizeSelection[2]) { // Large
      sizeMultiplier = 1.2;
    }
    
    setState(() {
      _totalPrice = (basePrice * sizeMultiplier) * _quantity;
    });
  }

  void _incrementQuantity() {
    setState(() { _quantity++; _calculatePrice(); });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() { _quantity--; _calculatePrice(); });
    }
  }
  
  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _getSelectedSize() {
      if (_sizeSelection[0]) return 'small';
      if (_sizeSelection[2]) return 'large';
      return 'medium';
  }

  @override
  Widget build(BuildContext context) {
    // UI tidak ada yang berubah, hanya logikanya
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transaction', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[100],
                    margin: const EdgeInsets.all(24),
                    child: Center(child: Icon(Icons.coffee_outlined, size: 80, color: Colors.grey[400])),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.menu.namaMenu, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              IconButton(icon: const Icon(Icons.remove), onPressed: _decrementQuantity, iconSize: 20),
                              Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(icon: const Icon(Icons.add), onPressed: _incrementQuantity, iconSize: 20),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Divider(height: 48),
                  ),
                  _buildOptionRow('Volume (ml)', _sizeSelection, ['small', 'Medium', 'Large'], (index) {
                    setState(() {
                      for (int i = 0; i < _sizeSelection.length; i++) {
                        _sizeSelection[i] = i == index;
                      }
                      _calculatePrice();
                    });
                  }),
                ],
              ),
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
                    const Text('Total Amount', style: TextStyle(color: Colors.grey)),
                    Text(_formatRupiah(_totalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final customizedItem = CustomizedOrderItem(
                        menu: widget.menu,
                        quantity: _quantity,
                        size: _getSelectedSize(),
                      );
                      Navigator.of(context).pop(customizedItem);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Next', style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

 Widget _buildOptionRow(String title, List<bool> selection, List<String> labels, Function(int) onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ToggleButtons(
            isSelected: selection,
            onPressed: onPressed,
            borderRadius: BorderRadius.circular(8),
            children: labels.map((label) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(label),
            )).toList(),
          )
        ],
      ),
    );
  }
}

