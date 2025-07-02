// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/screens/payment_screen.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My order',
          style: AppTextStyles.h4.copyWith(color: AppColors.darkGrey),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartService.items.isEmpty
                ? Center(
                    child: Text(
                      'Keranjang masih kosong!',
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.greyText),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    itemCount: cartService.items.length,
                    itemBuilder: (context, index) {
                      final item = cartService.items[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          cartService.removeItem(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} removed from cart'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: _buildCartItemCard(item),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.darkGrey),
                    ),
                    Consumer<CartService>(
                      builder: (context, cart, child) {
                        return Text(
                          formatRupiah(cart.totalPrice),
                          style: AppTextStyles.h3
                              .copyWith(color: AppColors.primaryColor),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (cartService.items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Keranjang masih kosong! Tidak bisa checkout.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            totalPrice: cartService.totalPrice,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Lanjut ke Pembayaran',
                            style: AppTextStyles.buttonText),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    // <<< PERUBAHAN UTAMA DI SINI >>>
    // Logika perhitungan harga per item disesuaikan dengan ukuran
    double price = item.pricePerItem;
    String customizations = item.customizations.toLowerCase();

    if (customizations.contains('small')) {
      price *= 0.8;
    } else if (customizations.contains('large')) {
      price *= 1.2;
    }
    
    final double totalItemPrice = price * item.quantity;
    // --- Batas Perubahan ---

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.image,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                        child: Icon(Icons.broken_image,
                            size: 30, color: Colors.grey[400])),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTextStyles.h4
                          .copyWith(fontSize: 16, color: AppColors.textColor)),
                  const SizedBox(height: 4),
                  Text(item.customizations,
                      style: AppTextStyles.bodyText2
                          .copyWith(color: AppColors.greyText)),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Tampilkan harga per item yang sudah benar
            Text(
              formatRupiah(totalItemPrice),
              style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppColors.primaryColor),
                  onPressed: () {
                    Provider.of<CartService>(context, listen: false)
                        .increaseQuantity(item.id);
                  },
                ),
                Text('${item.quantity}', style: AppTextStyles.bodyText1),
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: AppColors.primaryColor),
                  onPressed: () {
                    Provider.of<CartService>(context, listen: false)
                        .decreaseQuantity(item.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}