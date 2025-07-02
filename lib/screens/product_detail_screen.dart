// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/screens/cart_screen.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedRistretto = 'One';
  String _selectedOrderType = 'Onsite';
  String _selectedVolume = 'Medium'; // Default size
  bool _prepareByTime = false;
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    double basePrice = (widget.product['harga'] as num?)?.toDouble() ?? 0.0;
    
    // Logika untuk pengali harga berdasarkan ukuran
    double sizeMultiplier = 1.0; // Default untuk Medium
    if (_selectedVolume == 'Small') {
      sizeMultiplier = 0.8; // Diskon 20% untuk ukuran Small
    } else if (_selectedVolume == 'Large') {
      sizeMultiplier = 1.2; // Tambahan 20% untuk ukuran Large
    }

    setState(() {
      // Harga dihitung dengan mengalikan harga dasar, pengali ukuran, dan kuantitas
      _totalAmount = (basePrice * sizeMultiplier) * _quantity;
    });
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
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
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
                          widget.product['nama_menu'],
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.grey)),
                    Text(formatRupiah(_totalAmount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      double pricePerItem = (widget.product['harga'] as num?)?.toDouble() ?? 0.0;
                      int idMenu = (widget.product['id_menu'] as int?) ?? 0;
                      
                      cartService.addItem(
                        idMenu: idMenu,
                        name: widget.product['nama_menu'] as String,
                        image: 'assets/images/${(widget.product['nama_menu'] as String).toLowerCase().replaceAll(' ', '')}.png',
                        pricePerItem: pricePerItem,
                        quantity: _quantity,
                        customizations: '$_selectedRistretto | $_selectedOrderType | $_selectedVolume',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${widget.product['nama_menu']} ditambahkan ke keranjang')),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 40)
                    ),
                    child: const Text('Add to Cart', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
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