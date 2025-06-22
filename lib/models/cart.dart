// lib/models/cart.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Pastikan lo punya package uuid di pubspec.yaml

class CartItem {
  final String id; // Unique ID for each cart item
   final int idMenu;
  final String name;
  final String image;
  final double pricePerItem; // UBAH KE DOUBLE untuk fleksibilitas harga
  int quantity;
  final String customizations;

  CartItem({
    required this.id,
    required this.idMenu,
    required this.name,
    required this.image,
    required this.pricePerItem,
    required this.quantity,
    required this.customizations,
  });

  // Method untuk update quantity LANGSUNG DI CARTITEM
  void increaseQuantity() {
    quantity++;
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Uuid _uuid = const Uuid(); // Perbaikan: Uuid() harusnya const atau tidak

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + (item.pricePerItem * item.quantity));
  }

  void addItem({
    required String name,
    required String image,
    required double pricePerItem, // UBAH KE DOUBLE
    required int quantity,
    required String customizations,
    required int idMenu,
  }) {
    // Cek apakah item dengan kustomisasi yang sama sudah ada di keranjang
    final existingItemIndex = _items.indexWhere(
      (item) => item.name == name && item.customizations == customizations,
    );

    if (existingItemIndex != -1) {
      // Jika ada, tambahkan quantity
      _items[existingItemIndex].quantity += quantity;
    } else {
      // Jika tidak ada, tambahkan item baru
      _items.add(CartItem(
        id: _uuid.v4(), // Generate unique ID
        idMenu: idMenu, // <-- ISI ID MENU DI SINI
        name: name,
        image: image,
        pricePerItem: pricePerItem,
        quantity: quantity,
        customizations: customizations,
      ));
    }
    notifyListeners(); // Beri tahu UI bahwa data berubah
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void increaseQuantity(String id) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      _items[itemIndex].increaseQuantity(); // Memanggil method di CartItem
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      if (_items[itemIndex].quantity > 1) {
        _items[itemIndex].decreaseQuantity(); // Memanggil method di CartItem
      } else {
        // Hapus item jika quantitynya jadi 0 atau kurang
        _items.removeAt(itemIndex);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}