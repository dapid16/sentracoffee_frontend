// lib/utils/text_styles.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart'; // Import AppColors

class AppTextStyles {
  // Gaya teks yang lo punya (jika 'Reenie Beanie' adalah custom font)
  static const TextStyle title = TextStyle(
    fontFamily: 'Reenie Beanie', // Pastikan font ini sudah ditambahkan di pubspec.yaml
    fontSize: 55,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryColor, // Sesuaikan warna dengan primaryColor yang baru
  );

  // Gaya teks tambahan yang digunakan di PaymentScreen (sesuai Figma)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle h2 = TextStyle( // Untuk "Order payment"
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle h4 = TextStyle( // Untuk "Alex", "Credit Card", "Pay Now"
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semi-bold
    color: AppColors.textColor,
  );
  static const TextStyle bodyText1 = TextStyle( // Untuk "Amount", "Total Price" label
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );
  static const TextStyle bodyText2 = TextStyle( // Untuk subtitle seperti "Dana", "Seturan"
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText, // Menggunakan warna abu-abu untuk teks kecil
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.greyText,
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}