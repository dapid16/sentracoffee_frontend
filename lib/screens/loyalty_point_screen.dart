// lib/screens/loyalty_point_screen.dart (VERSI FINAL)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/loyalty.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';

class LoyaltyPointScreen extends StatefulWidget {
  const LoyaltyPointScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyPointScreen> createState() => _LoyaltyPointScreenState();
}

class _LoyaltyPointScreenState extends State<LoyaltyPointScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil service untuk fetch data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final customerName = authService.loggedInCustomer?.nama;
        if (customerName != null) {
          // Panggil service loyalty di sini jika perlu fetch data
          // Provider.of<LoyaltyService>(context, listen: false).fetchPoints(userName: customerName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyService>(
      builder: (context, loyaltyService, child) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.darkGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: -20,
                            right: -20,
                            child: Transform.rotate(
                              angle: -0.2,
                              child: Icon(
                                Icons.coffee,
                                size: 100,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('My Points:',
                                  style: AppTextStyles.bodyText1.copyWith(
                                      color: Colors.white.withOpacity(0.8))),
                              const SizedBox(height: 5),
                              Text(
                                '${formatNumberWithThousandsSeparator(loyaltyService.currentPoints.toDouble())} / ${formatNumberWithThousandsSeparator(loyaltyService.targetPoints.toDouble())}',
                                style: AppTextStyles.h2
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: SizedBox(
                                  height: 35,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // ... (Logika redeem sama) ...
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 3,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                    ),
                                    child: Text('Redeem drinks',
                                        style: AppTextStyles.buttonText
                                            .copyWith(fontSize: 14)),
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
                    style:
                        AppTextStyles.h3.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 15),
                  loyaltyService.history.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada riwayat poin.',
                            style: AppTextStyles.bodyText1
                                .copyWith(color: AppColors.greyText),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: loyaltyService.history.length,
                          itemBuilder: (context, index) {
                            final item = loyaltyService.history[index];
                            return _buildHistoryItem(item);
                          },
                        ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(RewardHistoryItem item) {
    Color pointsColor = item.points >= 0 ? Colors.green : Colors.red;
    String sign = item.points >= 0 ? '+' : '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.description,
                      style: AppTextStyles.bodyText1
                          .copyWith(color: AppColors.textColor)),
                  Text(
                    '${item.date.day} ${getMonthName(item.date.month)} | ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.greyText),
                  ),
                ],
              ),
              Text(
                '${sign} ${formatNumberWithThousandsSeparator(item.points.abs().toDouble())} Pts',
                style: AppTextStyles.h4.copyWith(color: pointsColor),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.lightGreyBackground),
      ],
    );
  }
}