// lib/screens/admin/product_options_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
// <-- PERUBAHAN: Import model TransactionCartItem
import 'package:sentra_coffee_frontend/screens/new_transaction_screen.dart'; 

// Model ini tetap sama seperti sebelumnya
class CustomizedOrderItem {
  final Menu menu;
  final int quantity;
  final String ristretto; 
  final String servingStyle;
  final String size; 

  CustomizedOrderItem({
    required this.menu,
    required this.quantity,
    required this.ristretto,
    required this.servingStyle,
    required this.size,
  });
}

class ProductOptionsScreen extends StatefulWidget {
  final Menu menu;
  // <-- PERUBAHAN: Tambahkan parameter opsional untuk menerima item yang akan diedit
  final TransactionCartItem? initialItem;

  const ProductOptionsScreen({
    Key? key, 
    required this.menu,
    this.initialItem, // <-- PERUBAHAN
  }) : super(key: key);

  @override
  State<ProductOptionsScreen> createState() => _ProductOptionsScreenState();
}

class _ProductOptionsScreenState extends State<ProductOptionsScreen> {
  // State management tidak berubah
  int _quantity = 1;
  int _ristrettoSelection = 0; 
  int _servingStyleSelection = 0;
  int _volumeSelection = 1; 
  
  late double _totalPrice;

  @override
  void initState() {
    super.initState();
    // <-- PERUBAHAN: Logika untuk mengisi state dari 'initialItem' jika ada (mode edit)
    if (widget.initialItem != null) {
      _quantity = widget.initialItem!.quantity;
      
      // Mapping string 'size' dari initialItem ke index integer '_volumeSelection'
      switch (widget.initialItem!.size) {
        case 'small':
          _volumeSelection = 0;
          break;
        case 'large':
          _volumeSelection = 2;
          break;
        default: // medium
          _volumeSelection = 1;
          break;
      }
      // Kamu bisa tambahkan mapping untuk ristretto dan serving style di sini jika sudah disimpan juga
    }
    
    _calculatePrice();
  }

  // Sisa kode di bawah ini tidak perlu diubah...
  // ... (fungsi _calculatePrice, _incrementQuantity, build, dll. tetap sama)

  // ... [PASTE SISA KODE DARI product_options_screen.dart SEBELUMNYA DI SINI] ...
  // Pastikan sisa kode dari file product_options_screen.dart (seperti _buildRistrettoOptions, _buildVolumeOptions, dll.)
  // tetap ada di bawah sini. Saya tidak menampilkannya lagi untuk meringkas.

  // --- Pastikan fungsi build dan semua helper widget dari jawaban sebelumnya ada di sini ---
  void _calculatePrice() {
    double basePrice = widget.menu.harga;
    double sizeMultiplier = 1.0;

    if (_volumeSelection == 0) { // Small
      sizeMultiplier = 0.8;
    } else if (_volumeSelection == 2) { // Large
      sizeMultiplier = 1.2;
    }

    setState(() {
      _totalPrice = (basePrice * sizeMultiplier) * _quantity;
    });
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _calculatePrice();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _calculatePrice();
      });
    }
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: const Text('Transaction',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network( 
                        "https://images.unsplash.com/photo-1517701550927-27cf9de0a283?q=80&w=1887&auto=format&fit=crop", 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return Icon(Icons.coffee_outlined, size: 80, color: Colors.grey[400]);
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.menu.namaMenu,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: _decrementQuantity),
                          SizedBox(
                            width: 40,
                            child: Text('$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          _buildQuantityButton(
                              icon: Icons.add, 
                              onPressed: _incrementQuantity),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                  _buildRistrettoOptions(),
                  const SizedBox(height: 24),
                  _buildServingStyleOptions(),
                  const SizedBox(height: 24),
                  _buildVolumeOptions(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }
  
  Widget _buildQuantityButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }
  
  Widget _buildRistrettoOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Ristretto', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            _buildOptionChip(
              label: 'One',
              isSelected: _ristrettoSelection == 0,
              onTap: () => setState(() {
                _ristrettoSelection = 0;
                _calculatePrice();
              }),
            ),
            const SizedBox(width: 8),
            _buildOptionChip(
              label: 'Two',
              isSelected: _ristrettoSelection == 1,
              onTap: () => setState(() {
                _ristrettoSelection = 1;
                _calculatePrice();
              }),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildServingStyleOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Onsite / Takeaway', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            _buildIconOption(
              icon: Icons.coffee_maker_outlined,
              isSelected: _servingStyleSelection == 0,
              onTap: () => setState(() {
                _servingStyleSelection = 0;
                _calculatePrice();
              }),
            ),
            const SizedBox(width: 8),
            _buildIconOption(
              icon: Icons.coffee_outlined,
              isSelected: _servingStyleSelection == 1,
              onTap: () => setState(() {
                _servingStyleSelection = 1;
                _calculatePrice();
              }),
            ),
          ],
        )
      ],
    );
  }
  
  Widget _buildVolumeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Volume (ml)', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildVolumeItem(
              icon: Icons.free_breakfast_outlined,
              label: 'small',
              isSelected: _volumeSelection == 0,
              onTap: () => setState(() {
                _volumeSelection = 0;
                _calculatePrice();
              }),
            ),
            _buildVolumeItem(
              icon: Icons.free_breakfast,
              label: 'Medium',
              isSelected: _volumeSelection == 1,
              onTap: () => setState(() {
                _volumeSelection = 1;
                _calculatePrice();
              }),
            ),
             _buildVolumeItem(
              icon: Icons.coffee,
              label: 'Large',
              isSelected: _volumeSelection == 2,
              onTap: () => setState(() {
                _volumeSelection = 2;
                _calculatePrice();
              }),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOptionChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300)
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }

   Widget _buildIconOption({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300)
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 28),
      ),
    );
  }

  Widget _buildVolumeItem({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Beri lebar agar konsisten
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
           color: isSelected ? Colors.black : const Color(0xFFF7F8FA),
           borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black))
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Amount',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(_formatRupiah(_totalPrice),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                final customizedItem = CustomizedOrderItem(
                  menu: widget.menu,
                  quantity: _quantity,
                  // NOTE: Kamu perlu memastikan model `CustomizedOrderItem` bisa menampung
                  // semua opsi ini jika ingin data ini juga ikut ter-update.
                  ristretto: _ristrettoSelection == 0 ? 'one' : 'two',
                  servingStyle: _servingStyleSelection == 0 ? 'onsite' : 'takeaway',
                  size: _volumeSelection == 0 ? 'small' : (_volumeSelection == 1 ? 'medium' : 'large'),
                );
                Navigator.of(context).pop(customizedItem);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 40)
              ),
              child: const Text('Next', style: TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

}