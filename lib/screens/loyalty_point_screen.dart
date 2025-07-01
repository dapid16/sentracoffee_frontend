// lib/screens/loyalty_point_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/loyalty_history.dart';
import 'package:sentra_coffee_frontend/screens/home_screen.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';

class LoyaltyPointScreen extends StatefulWidget {
  const LoyaltyPointScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyPointScreen> createState() => _LoyaltyPointScreenState();
}

class _LoyaltyPointScreenState extends State<LoyaltyPointScreen> {
  late Future<List<LoyaltyHistory>> _historyFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Ambil customerId dari AuthService dan panggil API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.isLoggedIn) {
        setState(() {
          _historyFuture =
              _apiService.fetchLoyaltyHistory(authService.loggedInCustomer!.idCustomer);
        });
      }
    });
  }

  String formatNumberWithThousandsSeparator(int number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  void _handleRedeem(BuildContext context, int currentPoints, int targetPoints) {
    if (currentPoints >= targetPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode redeem aktif! Pilih minuman gratis Anda di menu.'),
          backgroundColor: Colors.green,
        ),
      );
      // Pindah ke halaman menu/home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poin Anda tidak cukup untuk melakukan redeem.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final int currentPoints = authService.loggedInCustomer?.points ?? 0;
        final int targetPoints = 25000;

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
                  _buildPointsCard(
                      context, currentPoints, targetPoints, _handleRedeem),
                  const SizedBox(height: 30),
                  Text(
                    'History Rewards',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 15),
                  // Widget untuk menampilkan riwayat dari API
                  _buildHistoryList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsCard(
      BuildContext context, int current, int target, Function a) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.darkGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Points:',
                style: AppTextStyles.bodyText1
                    .copyWith(color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 5),
            Text(
              '${formatNumberWithThousandsSeparator(current)} / ${formatNumberWithThousandsSeparator(target)}',
              style: AppTextStyles.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                height: 35,
                child: ElevatedButton(
                  // --- FUNGSI REDEEM DIPANGGIL DI SINI ---
                  onPressed: () => _handleRedeem(context, current, target),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Redeem drinks',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return FutureBuilder<List<LoyaltyHistory>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat poin.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final histories = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final history = histories[index];
            bool isEarned = history.pointsChange >= 0;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  isEarned ? Icons.add_circle : Icons.remove_circle,
                  color: isEarned ? Colors.green : Colors.red,
                ),
                title: Text(
                  history.description ?? 'Transaksi',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('d MMM yyyy, HH:mm').format(history.historyDate),
                ),
                trailing: Text(
                  '${isEarned ? '+' : ''}${history.pointsChange} Pts',
                  style: TextStyle(
                    color: isEarned ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}