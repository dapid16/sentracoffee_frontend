// lib/screens/payment_success_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/home_screen.dart'; // Import HomeScreen untuk navigasi

class PaymentSuccessScreen extends StatelessWidget {
  // Lo bisa tambahin parameter di sini kalau mau detailnya dinamis, contoh:
  // final String orderTime;
  // final String deliveryAddress;
  // const PaymentSuccessScreen({Key? key, this.orderTime = '18:10', this.deliveryAddress = 'Seturan'}) : super(key: key);

  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk waktu dan alamat (bisa diganti dengan parameter nanti)
    final String dummyOrderTime = '18:10';
    final String dummyDeliveryAddress = 'Seturan';

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () {
            // Langsung kembali ke home jika user tekan tombol back di AppBar
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen(userName: "",)),
              (Route<dynamic> route) => false, // Hapus semua route di stack
            );
          },
        ),
        // Title di AppBar kosong karena desain Figma hanya ada icon back
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- INI BAGIAN YANG DIUBAH DARI ICON KE IMAGE.ASSET ---
                  Container(
                    width: 150, // Sesuaikan lebar gambar
                    height: 150, // Sesuaikan tinggi gambar
                    child: Image.asset(
                      'assets/images/order_success.png', // <-- PASTIKAN PATH GAMBAR LO DI SINI
                      fit:
                          BoxFit.contain, // Biar gambar muat di dalam container
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          // Fallback jika gambar tidak ditemukan
                          width: 150, height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 80, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  // --- AKHIR DARI BAGIAN YANG DIUBAH ---

                  const SizedBox(height: 30),

                  // Teks "Ordered"
                  Text(
                    'Ordered',
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 10),

                  // Pesan Konfirmasi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Alex, your order has been successfully placed.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.greyText),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Detail Pesanan (Waktu dan Alamat)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'The order will be ready today to $dummyOrderTime at the address $dummyDeliveryAddress.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText1.copyWith(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Instruksi QR Code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Submit your personal QR code at a coffee shop to receive an order.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText2
                          .copyWith(color: AppColors.greyText),
                    ),
                  ),
                ],
              ),
            ),
            // Tombol "Back to Home"
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Navigasi kembali ke Home Screen dan hapus semua route di stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(userName: "widget.userName")),
                    (Route<dynamic> route) =>
                        false, // Ini akan menghapus semua route sebelumnya
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Back to Home',
                  style: AppTextStyles.h4.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30), // Padding bawah
          ],
        ),
      ),
    );
  }
}
