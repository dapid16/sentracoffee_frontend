// lib/models/order.dart

import 'package:flutter/material.dart'; // Untuk IconData

class OrderItem {
  final String itemName;
  final IconData icon; // IconData langsung dari Flutter Icons

  OrderItem({required this.itemName, required this.icon});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Mapping string icon_code dari backend ke IconData Flutter
    IconData mappedIcon;
    switch (json['icon_code']) {
      case 'coffee_outlined':
        mappedIcon = Icons.coffee_outlined;
        break;
      case 'local_cafe_outlined':
        mappedIcon = Icons.local_cafe_outlined;
        break;
      case 'bakery_dining_outlined':
        mappedIcon = Icons.bakery_dining_outlined;
        break;
      case 'storefront_outlined':
        mappedIcon = Icons.storefront_outlined;
        break;
      case 'takeout_dining_outlined':
        mappedIcon = Icons.takeout_dining_outlined;
        break;
      case 'emoji_food_beverage_outlined':
        mappedIcon = Icons.emoji_food_beverage_outlined;
        break;
      default:
        mappedIcon = Icons.question_mark_outlined; // Fallback icon
    }
    return OrderItem(
      itemName: json['item_name'],
      icon: mappedIcon,
    );
  }
}

class Order {
  final String id;
  final String dateTime;
  final String status; // Misalnya "On going" atau "History"
  final List<OrderItem> items;
  final String location;
  final double totalPrice;

  Order({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.items,
    required this.location,
    required this.totalPrice,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parsing daftar item
    var itemsList = json['items'] as List;
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'],
      dateTime: json['date_time'],
      status: json['status'],
      items: parsedItems,
      location: json['location'],
      totalPrice: json['total_price'].toDouble(), // Pastikan double
    );
  }
}