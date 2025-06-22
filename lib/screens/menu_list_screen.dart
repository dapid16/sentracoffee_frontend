// lib/screens/menu_list_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/product_detail_screen.dart';

class MenuListScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  MenuListScreen({Key? key}) : super(key: key);

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
        future: apiService.fetchAllMenu(),
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.lightGreyBackground, width: 1.0),
                  ),
                  elevation: 2,
                  color: AppColors.backgroundColor,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      // --- INI BAGIAN YANG DIUBAH ---
                      // Langsung gunakan AssetImage dan biarkan errorBuilder menangani fallback
                      backgroundImage: AssetImage(
                        'assets/images/${menu.namaMenu.toLowerCase().replaceAll(' ', '')}.png',
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Fallback jika gambar tidak ditemukan, tampilkan Icon kopi di tengah CircleAvatar
                        print('Error loading image for ${menu.namaMenu}: $exception');
                        // Return null di onBackgroundImageError tidak menampilkan child.
                        // Jadi, kita bisa pakai child di CircleAvatar sebagai fallback utama.
                      },
                      child: (menu.namaMenu == null || menu.namaMenu.isEmpty) // Contoh fallback kalau namaMenu kosong atau tidak ada gambar
                          ? Icon(Icons.coffee, color: AppColors.primaryColor, size: 30)
                          : null, // Jangan pakai menu.image lagi
                      // --- AKHIR BAGIAN YANG DIUBAH ---
                    ),
                    title: Text(
                      menu.namaMenu,
                      style: AppTextStyles.h4.copyWith(fontSize: 18, color: AppColors.textColor),
                    ),
                    subtitle: Text(
                      'Kategori: ${menu.kategori}\nKetersediaan: ${menu.isAvailable ? 'Ada' : 'Kosong'}',
                      style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText),
                    ),
                    trailing: Text(
                      formatRupiah(menu.harga),
                      style: AppTextStyles.bodyText1.copyWith(fontWeight: FontWeight.bold, color: AppColors.textColor),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: menu.toJson()),
                        ),
                      );
                      print('Menu ${menu.namaMenu} tapped!');
                    },
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