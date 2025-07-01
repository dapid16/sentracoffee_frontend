// lib/screens/admin_wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/wallet_report.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<List<WalletReport>> _walletFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _walletFuture = _apiService.fetchWalletReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Wallet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<WalletReport>>(
        future: _walletFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data laporan.'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _buildReportCard(reports[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportCard(WalletReport report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.monthName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.totalRevenue,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pemasukan dari:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Loop untuk menampilkan breakdown metode pembayaran
            ...report.breakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                child: Row(
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    SizedBox(
                      width: 100, // Atur lebar agar titik dua sejajar
                      child: Text(entry.key, style: const TextStyle(fontSize: 16)),
                    ),
                    const Text(': ', style: TextStyle(fontSize: 16)),
                    Text(entry.value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Text(
              report.comparison,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}