// lib/models/cart.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CartItem {
  final String id;
  final int idMenu;
  final String name;
  final String image;
  final double pricePerItem;
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
  final Uuid _uuid = const Uuid();

  List<CartItem> get items => List.unmodifiable(_items);

  // <<< PERUBAHAN UTAMA ADA DI SINI >>>
  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      // Ambil harga dasar
      double price = item.pricePerItem;
      String customizations = item.customizations.toLowerCase();

      // Terapkan pengali harga berdasarkan ukuran dari string kustomisasi
      if (customizations.contains('small')) {
        price *= 0.8;
      } else if (customizations.contains('large')) {
        price *= 1.2;
      }
      
      // Kembalikan total yang sudah disesuaikan
      return sum + (price * item.quantity);
    });
  }

  void addItem({
    required String name,
    required String image,
    required double pricePerItem,
    required int quantity,
    required String customizations,
    required int idMenu,
  }) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.name == name && item.customizations == customizations,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: _uuid.v4(),
        idMenu: idMenu,
        name: name,
        image: image,
        pricePerItem: pricePerItem,
        quantity: quantity,
        customizations: customizations,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void increaseQuantity(String id) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      _items[itemIndex].increaseQuantity();
      notifyListeners();
    }
  }

  void decreaseQuantity(String id) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      if (_items[itemIndex].quantity > 1) {
        _items[itemIndex].decreaseQuantity();
      } else {
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