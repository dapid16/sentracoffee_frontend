import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/menu.dart'; 
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/screens/checkout_screen.dart';
import 'package:sentra_coffee_frontend/screens/product_options_screen.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({Key? key}) : super(key: key);

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Menu>> _menuFuture;

  final TextEditingController _searchController = TextEditingController();
  List<Menu> _allMenus = [];
  List<Menu> _filteredMenus = [];

  final List<TransactionCartItem> _currentOrder = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _menuFuture = _apiService.fetchAllMenusForAdmin(); 
    _menuFuture.then((menus) {
      if (mounted) {
        setState(() {
          _allMenus = menus;
          _filteredMenus = menus;
        });
      }
    });
    _searchController.addListener(_filterMenus);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMenus() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMenus = _allMenus
          .where((menu) => menu.namaMenu.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addItemToOrder(CustomizedOrderItem customizedItem) {
    setState(() {
      var existingItemIndex = _currentOrder.indexWhere((item) =>
          item.menu.idMenu == customizedItem.menu.idMenu &&
          item.size == customizedItem.size &&
          item.ristretto == customizedItem.ristretto &&
          item.servingStyle == customizedItem.servingStyle);

      if (existingItemIndex != -1) {
        _currentOrder[existingItemIndex].quantity += customizedItem.quantity;
      } else {
        _currentOrder.add(TransactionCartItem(
          menu: customizedItem.menu,
          quantity: customizedItem.quantity,
          size: customizedItem.size,
          ristretto: customizedItem.ristretto,
          servingStyle: customizedItem.servingStyle,
        ));
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _currentOrder) {
      double basePrice = item.menu.harga;
      if (item.size.toLowerCase().contains('small')) {
        basePrice *= 0.8;
      } else if (item.size.toLowerCase().contains('large')) {
        basePrice *= 1.2;
      }
      total += basePrice * item.quantity;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transaction',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Find Product',
                prefixIcon: const Icon(Icons.menu, color: Colors.grey),
                suffixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Menu>>(
              future: _menuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (_filteredMenus.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return const Center(
                      child: Text('Menu yang dicari tidak ada.'));
                }
                if (_allMenus.isEmpty) {
                  return const Center(child: Text('Belum ada menu tersedia.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredMenus.length,
                  itemBuilder: (context, index) {
                    final menu = _filteredMenus[index];
                    return _buildMenuCard(menu);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _currentOrder.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                final List<TransactionCartItem>? updatedOrder =
                    await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      orderItems: _currentOrder,
                      totalPrice: _totalPrice,
                    ),
                  ),
                );
                if (updatedOrder != null) {
                  setState(() {
                    _currentOrder.clear();
                    _currentOrder.addAll(updatedOrder);
                    _calculateTotal();
                  });
                }
              },
              label: Text(
                  '${_currentOrder.length} Items | ${_formatRupiah(_totalPrice)}'),
              icon: const Icon(Icons.shopping_cart_checkout),
              backgroundColor: Colors.black,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMenuCard(Menu menu) {
    final String imageUrl = 'http://localhost/SentraCoffee/uploads/${menu.image}';
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<CustomizedOrderItem>(
            context,
            MaterialPageRoute(
                builder: (context) => ProductOptionsScreen(menu: menu)),
          );
          if (result != null) {
            _addItemToOrder(result);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${result.menu.namaMenu} ditambahkan ke keranjang.'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (menu.image != null && menu.image!.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.coffee_outlined, size: 50, color: Colors.grey[600]),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.coffee_outlined, size: 50, color: Colors.grey[600]),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.namaMenu,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(menu.harga), style: TextStyle(color: Colors.brown)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}