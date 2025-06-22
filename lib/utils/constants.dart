// lib/utils/constants.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  // Warna Utama (misalnya untuk tombol, harga total, radio button aktif)
  // Berdasarkan Figma, ini terlihat seperti cokelat gelap atau hampir hitam
  static const Color primaryColor = Color(0xFF5D4037); // Contoh Cokelat Kopi Gelap (deep brown)
  static const Color secondaryColor = Color(0xFFD2B48C); // Contoh warna pendukung (Tan) - dari sebelumnya, bisa disesuaikan

  // Warna Background
  static const Color lightGreyBackground = Color(0xFFF5F5F5); // Background abu muda dari Figma
  static const Color backgroundColor = Color(0xFFFFFFFF); // Putih (untuk card, seperti di Figma)

  // Warna Teks
  static const Color textColor = Color(0xFF333333); // Teks Umum (dark grey)
  static const Color darkGrey = Color(0xFF424242); // Teks abu-abu gelap (seperti di "My order" title)
  static const Color greyText = Color(0xFF757575); // Teks abu-abu ringan (seperti "Seturan", subtitle)

  // ...Jika ada warna lain di Figma lo yang belum ada, bisa ditambahkan di sini
}

String formatRupiah(double amount) {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'id_ID', // Untuk format Indonesia
    symbol: 'Rp',    // Simbol mata uang
    decimalDigits: 0, // Tidak ada digit desimal
  );
  return formatter.format(amount);
}

String formatNumberWithThousandsSeparator(double amount) {
  final NumberFormat formatter = NumberFormat('#,###', 'id_ID');
  return formatter.format(amount);
}

String getMonthName(int month) {
  switch (month) {
    case 1: return 'Jan';
    case 2: return 'Feb';
    case 3: return 'Mar';
    case 4: return 'Apr';
    case 5: return 'May';
    case 6: return 'June';
    case 7: return 'Jul';
    case 8: return 'Aug';
    case 9: return 'Sep';
    case 10: return 'Oct';
    case 11: return 'Nov';
    case 12: return 'Dec';
    default: return '';
  }
}