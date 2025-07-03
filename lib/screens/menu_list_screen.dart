// lib/screens/menu_list_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/product_detail_screen.dart';
import 'package:intl/intl.dart';

class MenuListScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  final String _imageBaseUrl = 'http://localhost/SentraCoffee/uploads/';

  MenuListScreen({Key? key}) : super(key: key);

  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'Daftar Menu',
          style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Menu>>(
        future: apiService.fetchAvailableMenus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: AppTextStyles.bodyText1.copyWith(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Menu kosong', style: AppTextStyles.bodyText1.copyWith(color: AppColors.greyText)));
          } else {
            final List<Menu> menus = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                final bool hasImage = menu.image != null && menu.image!.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: menu.toJson()),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: hasImage
                              ? Image.network(
                                  '$_imageBaseUrl${menu.image}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey));
                                  },
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.coffee_outlined, color: Colors.grey)),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.namaMenu,
                                  style: AppTextStyles.h4.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kategori: ${menu.kategori}',
                                  style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatRupiah(menu.harga),
                                  style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}