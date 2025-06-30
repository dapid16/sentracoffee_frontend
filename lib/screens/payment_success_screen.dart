// lib/screens/payment_success_screen.dart (VERSI FINAL)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <<< IMPORT PROVIDER
import 'package:sentra_coffee_frontend/services/auth_service.dart'; // <<< IMPORT AUTHSERVICE
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN #1: Ambil data user dari AuthService ---
    final authService = Provider.of<AuthService>(context, listen: false);
    final String userName = authService.loggedInCustomer?.nama ?? 'User';

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
            // --- PERBAIKAN #2: Navigasi ke HomeScreen tanpa parameter ---
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/images/order_success.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 80, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Ordered',
                    style:
                        AppTextStyles.h2.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      // --- PERBAIKAN #3: Gunakan userName dinamis ---
                      '$userName, your order has been successfully placed.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.greyText),
                    ),
                  ),
                  const SizedBox(height: 40),
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
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // --- PERBAIKAN #4: Navigasi ke HomeScreen tanpa parameter ---
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}