// lib/screens/loyalty_point_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';

class LoyaltyPointScreen extends StatelessWidget {
  const LoyaltyPointScreen({Key? key}) : super(key: key);

  String formatNumberWithThousandsSeparator(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final int currentPoints = authService.loggedInCustomer?.points ?? 0;
        // --- PERUBAHAN DI SINI ---
        final int targetPoints = 25000; 
        // -------------------------

        return Scaffold(
          backgroundColor: AppColors.lightGreyBackground,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.lightGreyBackground,
            elevation: 0,
            title: Text(
              'Rewards',
              style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.darkGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: -20, right: -20,
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Icon(Icons.coffee, size: 100, color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('My Points:', style: AppTextStyles.bodyText1.copyWith(color: Colors.white.withOpacity(0.8))),
                              const SizedBox(height: 5),
                              Text(
                                '${formatNumberWithThousandsSeparator(currentPoints.toDouble())} / ${formatNumberWithThousandsSeparator(targetPoints.toDouble())}',
                                style: AppTextStyles.h2.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  height: 35,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 3,
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                    ),
                                    child: Text('Redeem drinks', style: AppTextStyles.buttonText.copyWith(fontSize: 14)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'History Rewards',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      'Riwayat poin akan ditampilkan di sini.',
                      style: AppTextStyles.bodyText1.copyWith(color: AppColors.greyText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}