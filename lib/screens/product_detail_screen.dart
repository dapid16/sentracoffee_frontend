// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/screens/cart_screen.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/screens/payment_screen.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart'; // Untuk formatRupiah, dll.
import 'package:sentra_coffee_frontend/utils/text_styles.dart'; // Untuk AppTextStyles
import 'package:sentra_coffee_frontend/models/menu.dart'; // Import model Menu

class ProductDetailScreen extends StatefulWidget {
  // Menerima Map<String, dynamic> karena dikirim dari Menu.toJson()
  final Map<String, dynamic> product;
  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedRistretto = 'One';
  String _selectedOrderType = 'Onsite';
  String _selectedVolume = 'Medium';
  bool _prepareByTime = false;
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    // UBAH: Ambil 'harga' dari widget.product, dan pastikan itu double
    // Gunakan 'as num?' lalu .toDouble() untuk null-safety, dan ?? 0.0 sebagai default jika null
    double basePrice = (widget.product['harga'] as num?)?.toDouble() ?? 0.0; // <-- PERBAIKAN DI SINI!
    _totalAmount = basePrice * _quantity;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Order',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              print('Cart icon tapped!');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    // Asumsi path gambar
                    'assets/images/${(widget.product['nama_menu'] as String).toLowerCase().replaceAll(' ', '')}.png',
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                        ),
                        child: Center(
                          child: Icon(Icons.broken_image, size: 80, color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product['nama_menu'], // Gunakan nama_menu
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildQuantitySelector(),
                ],
              ),
              const SizedBox(height: 32),
              _buildOptionSection(
                title: 'Ristretto',
                options: ['One', 'Two'],
                selectedValue: _selectedRistretto,
                onSelected: (value) {
                  setState(() {
                    _selectedRistretto = value;
                    _calculateTotalAmount();
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildIconOptionSection(
                title: 'Onsite / Takeaway',
                options: [
                  {'value': 'Onsite', 'icon': Icons.storefront_outlined},
                  {'value': 'Takeaway', 'icon': Icons.takeout_dining_outlined},
                ],
                selectedValue: _selectedOrderType,
                onSelected: (value) {
                  setState(() {
                    _selectedOrderType = value;
                    _calculateTotalAmount();
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildIconOptionSection(
                title: 'Volume',
                options: [
                  {'value': 'Small', 'icon': Icons.local_cafe_outlined},
                  {'value': 'Medium', 'icon': Icons.coffee_outlined},
                  {'value': 'Large', 'icon': Icons.emoji_food_beverage_outlined},
                ],
                selectedValue: _selectedVolume,
                onSelected: (value) {
                  setState(() {
                    _selectedVolume = value;
                    _calculateTotalAmount();
                  });
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prepare by a certain time today?',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Switch(
                    value: _prepareByTime,
                    onChanged: (bool value) {
                      setState(() {
                        _prepareByTime = value;
                      });
                    },
                    activeColor: Colors.brown,
                  ),
                ],
              ),
              if (_prepareByTime)
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.brown,
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.brown,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    formatRupiah(_totalAmount),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Ambil harga yang benar dari widget.product (yaitu 'harga')
                    double pricePerItem = (widget.product['harga'] as num?)?.toDouble() ?? 0.0; // <-- PERBAIKAN DI SINI JUGA!
                    int idMenu = (widget.product['id_menu'] as int?) ?? 0; // <-- Ambil id_menu
                    
                    cartService.addItem(
                      idMenu: idMenu, // <-- KIRIM idMenu DI SINI!
                      name: widget.product['nama_menu'] as String, // Gunakan nama_menu
                      image: 'assets/images/${(widget.product['nama_menu'] as String).toLowerCase().replaceAll(' ', '')}.png', // Asumsi path gambar
                      pricePerItem: pricePerItem,
                      quantity: _quantity,
                      customizations:
                          '${_selectedRistretto} | ${_selectedOrderType} | ${_selectedVolume}',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.product['nama_menu']} ditambahkan ke keranjang')),
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20, color: Colors.black),
            onPressed: () {
              setState(() {
                if (_quantity > 1) {
                  _quantity--;
                  _calculateTotalAmount();
                }
              });
            },
          ),
          Text(
            '$_quantity',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20, color: Colors.black),
            onPressed: () {
              setState(() {
                _quantity++;
                _calculateTotalAmount();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            bool isSelected = option == selectedValue;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(option),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.brown : Colors.white,
                    border: Border.all(color: isSelected ? Colors.brown : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconOptionSection({
    required String title,
    required List<Map<String, dynamic>> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            bool isSelected = option['value'] == selectedValue;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(option['value']),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.brown : Colors.white,
                    border: Border.all(color: isSelected ? Colors.brown : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        option['icon'],
                        color: isSelected ? Colors.white : Colors.black,
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['value'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}