// lib/models/wallet_report.dart

import 'dart:convert';

List<WalletReport> walletReportFromJson(String str) => List<WalletReport>.from(
    json.decode(str)["reports"].map((x) => WalletReport.fromJson(x)));

class WalletReport {
  final String monthName;
  final String totalRevenue;
  final String comparison;
  final Map<String, String> breakdown;

  WalletReport({
    required this.monthName,
    required this.totalRevenue,
    required this.comparison,
    required this.breakdown,
  });

  factory WalletReport.fromJson(Map<String, dynamic> json) {
    return WalletReport(
      monthName: json["month_name"],
      totalRevenue: json["total_revenue"],
      comparison: json["comparison"],
      // Konversi Map<String, dynamic> ke Map<String, String>
      breakdown: Map<String, String>.from(json["breakdown"]),
    );
  }
}