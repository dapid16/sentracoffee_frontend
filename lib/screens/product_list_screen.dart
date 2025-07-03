import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/screens/add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Menu>> _menuItemsFuture;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Menu> _allMenus = [];
  List<Menu> _filteredMenus = [];
  final String _imageBaseUrl = 'http://localhost/SentraCoffee/uploads/';

  @override
  void initState() {
    super.initState();
    _loadMenus();
    _searchController.addListener(_filterMenus);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMenus() {
    setState(() {
      _menuItemsFuture = _apiService.fetchAllMenusForAdmin();
      _menuItemsFuture.then((menus) {
        if (mounted) {
          setState(() {
            _allMenus = menus;
            _filteredMenus = menus;
          });
        }
      });
    });
  }

  void _filterMenus() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMenus = _allMenus.where((menu) {
        return menu.namaMenu.toLowerCase().contains(query);
      }).toList();
    });
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }
  
  Future<void> _navigateToEditScreen(Menu menu) async {
    final bool? isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen(menuToEdit: menu)),
    );
    if (isSuccess == true) {
      _loadMenus();
    }
  }

  Future<void> _navigateToAddScreen() async {
    final bool? isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
    if (isSuccess == true) {
      _loadMenus();
    }
  }

  Future<void> _deleteProduct(int idMenu) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menonaktifkan produk ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Nonaktifkan', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final bool success = await _apiService.deleteMenu(idMenu);
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dinonaktifkan!'), backgroundColor: Colors.green),
          );
          _loadMenus();
        } else {
          throw Exception('Gagal menonaktifkan produk dari server.');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
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
        title: const Text('Product', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Find Product',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Menu>>(
                future: _menuItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada menu yang ditemukan.'));
                  }
                  if (_filteredMenus.isEmpty && _searchController.text.isNotEmpty) {
                    return const Center(child: Text('Produk tidak ditemukan.'));
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredMenus.length,
                    itemBuilder: (context, index) {
                      final menu = _filteredMenus[index];
                      final bool hasImage = menu.image != null && menu.image!.isNotEmpty;
                      
                      return Card(
                        color: menu.isAvailable ? Colors.white : Colors.grey[300],
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _navigateToEditScreen(menu),
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: hasImage
                                      ? Image.network(
                                          '$_imageBaseUrl${menu.image}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 40));
                                          },
                                        )
                                      : const Center(
                                          child: Icon(Icons.coffee,
                                              color: Colors.grey, size: 40),
                                        ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menu.namaMenu,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatRupiah(menu.harga),
                                          style: TextStyle(
                                              color: menu.isAvailable ? Theme.of(context).primaryColor : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (menu.isAvailable)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _deleteProduct(menu.idMenu),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        backgroundColor: Colors.blueGrey[900],
        child: const Icon(Icons.add),
      ),
    );
  }
}