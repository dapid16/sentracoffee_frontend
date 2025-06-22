// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/payment_success_screen.dart';
import 'package:sentra_coffee_frontend/models/loyalty.dart';
import 'package:sentra_coffee_frontend/models/cart.dart'; // Import CartService
import 'package:sentra_coffee_frontend/services/api_service.dart'; // <-- TAMBAHKAN INI
import 'package:sentra_coffee_frontend/services/auth_service.dart'; // <-- TAMBAHKAN INI untuk id_customer

class PaymentScreen extends StatefulWidget {
  final double totalPrice; // Total harga dari CartScreen

  const PaymentScreen({Key? key, required this.totalPrice}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod; // Set default selection ke 'dana' atau null

  double get _subtotalAmount => widget.totalPrice;
  double get _finalPaymentAmount => _subtotalAmount; // Tanpa biaya tambahan atau diskon

  @override
  void initState() {
    super.initState();
    // Jika user datang dari redeem process, secara otomatis pilih 'point'
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loyaltyService = Provider.of<LoyaltyService>(context, listen: false);
      if (loyaltyService.isRedeeming) {
        setState(() {
          _selectedPaymentMethod = 'point';
        });
      } else {
        _selectedPaymentMethod = 'dana'; // Default non-redeem
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Ambil instance LoyaltyService, CartService, dan AuthService
    final loyaltyService = Provider.of<LoyaltyService>(context); // Listen: true agar UI update jika isRedeeming berubah
    final cartService = Provider.of<CartService>(context, listen: false); // listen: false karena cuma mau panggil method
    final authService = Provider.of<AuthService>(context, listen: false); // <-- Ambil AuthService

    // Tentukan harga dan tampilan berdasarkan mode redeem
    double displayedAmount = _subtotalAmount;
    double displayedFinalAmount = _finalPaymentAmount;
    String amountPrefix = 'Rp';
    String totalPricePrefix = 'Rp';
    Color totalPriceColor = AppColors.primaryColor;

    if (loyaltyService.isRedeeming) {
      // Dalam mode redeem, harga ditampilkan 0
      displayedAmount = 0;
      displayedFinalAmount = 0;
      amountPrefix = ''; // Kosongkan prefix karena akan ada "Point" di akhir
      totalPricePrefix = '';
      totalPriceColor = AppColors.textColor; // Warna teks biasa untuk poin/gratis
      // Otomatis pilih metode 'point' jika sedang dalam mode redeem
      if (_selectedPaymentMethod != 'point') {
        _selectedPaymentMethod = 'point'; // Update state ini agar radio button terpilih
      }
    }


    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () {
            // Jika user keluar dari payment saat mode redeem aktif, batalkan mode redeem
            if (loyaltyService.isRedeeming) {
              loyaltyService.setRedeeming(false);
            }
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'My order',
          style: AppTextStyles.h4.copyWith(color: AppColors.darkGrey),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order payment',
                  style: AppTextStyles.h2.copyWith(color: AppColors.textColor),
                ),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreyBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.shopping_cart_outlined, color: AppColors.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alex', style: AppTextStyles.h4),
                            Text('Magic Coffee store', style: AppTextStyles.bodyText1.copyWith(color: AppColors.darkGrey)),
                            Text('Seturan', style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Detail Pesanan',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', displayedAmount, prefix: amountPrefix),
                        const Divider(height: 20, color: AppColors.lightGreyBackground),
                        _buildSummaryRow('Jumlah Dibayar', displayedFinalAmount, isTotal: true, prefix: totalPricePrefix, valueColor: totalPriceColor),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pilih Metode Pembayaran',
                  style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
                ),
                const SizedBox(height: 10),
                if (!loyaltyService.isRedeeming) ...[
                  _buildPaymentOption(
                    context,
                    value: 'dana',
                    groupValue: _selectedPaymentMethod,
                    title: 'Online payment',
                    subtitle: 'Dana',
                    logoAsset: 'assets/images/logo_dana.png',
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    context,
                    value: 'credit_card',
                    groupValue: _selectedPaymentMethod,
                    title: 'Credit Card',
                    subtitle: '2540 xxxx xxxx 2648',
                    logoAsset: 'assets/images/logo_visa_mastercard.png',
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                _buildPaymentOption(
                  context,
                  value: 'point',
                  groupValue: _selectedPaymentMethod,
                  title: 'Point',
                  subtitle: loyaltyService.isRedeeming ? 'Poin akan dipotong' : 'Redeem your point',
                  onChanged: (String? value) {
                    if (!loyaltyService.isRedeeming) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anda dalam mode redeem. Metode pembayaran tidak bisa diubah.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount', style: AppTextStyles.bodyText1.copyWith(color: AppColors.darkGrey)),
                      Text(
                        '${amountPrefix}${formatNumberWithThousandsSeparator(displayedAmount)}',
                        style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Price', style: AppTextStyles.bodyText1.copyWith(color: AppColors.darkGrey)),
                      Text(
                        '${totalPricePrefix}${formatNumberWithThousandsSeparator(displayedFinalAmount)}',
                        style: AppTextStyles.h2.copyWith(color: totalPriceColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async { // <-- Ubah jadi async
                        if (_selectedPaymentMethod == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu!')),
                          );
                          return;
                        }

                        // Pastikan user sudah login untuk mendapatkan id_customer
                        if (!authService.isLoggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Anda harus login untuk membuat pesanan.')),
                            );
                            return;
                        }

                        int? customerId = authService.loggedInCustomer?.idCustomer;
                        if (customerId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ID pelanggan tidak ditemukan. Mohon login ulang.')),
                            );
                            return;
                        }

                        // Ambil ApiService instance
                        final apiService = ApiService(); // <-- Inisialisasi ApiService di sini
                        String snackBarMessage = '';
                        Color snackBarColor = Colors.red;

                        try {
                          if (loyaltyService.isRedeeming) {
                            // --- LOGIKA PEMBAYARAN REDEEM ---
                            if (_selectedPaymentMethod != 'point') {
                               snackBarMessage = 'Dalam mode redeem, pembayaran hanya bisa dengan Poin!';
                            } else {
                               int pointsToDeduct = loyaltyService.targetPoints; // Poin yang dipotong adalah target redeem
                               if (loyaltyService.deductPoints(pointsToDeduct)) { // Poin dipotong oleh frontend, history dicatat di sini
                                  // Kirim order ke backend (harga 0, poin -targetPoints)
                                  final response = await apiService.createOrder( // <-- Panggil createOrder
                                      idCustomer: customerId,
                                      paymentMethod: _selectedPaymentMethod!,
                                      totalAmount: 0.0, // Harga 0 untuk redeem
                                      pointsEarned: -pointsToDeduct, // Poin yang berkurang dari redeem
                                      cartItems: cartService.items, // Kirim semua item di keranjang
                                      status: 'Redeemed', // Status khusus untuk redeem
                                  );

                                  if (response['success']) {
                                      cartService.clearCart(); // Bersihkan keranjang
                                      loyaltyService.setRedeeming(false); // Nonaktifkan mode redeem
                                      snackBarMessage = 'Redeem berhasil! Minuman Anda gratis.';
                                      snackBarColor = Colors.green;
                                  } else {
                                      snackBarMessage = response['message'] ?? 'Redeem gagal.';
                                  }
                               } else {
                                  snackBarMessage = 'Terjadi kesalahan. Poin tidak cukup saat pembayaran.'; // Seharusnya sudah divalidasi sebelumnya
                               }
                            }
                          } else {
                            // --- LOGIKA PEMBAYARAN NORMAL ---
                            int pointsEarned = (widget.totalPrice * 0.1).round(); // Hitung poin untuk dikirim ke backend
                            
                            final response = await apiService.createOrder( // <-- Panggil createOrder
                                idCustomer: customerId,
                                paymentMethod: _selectedPaymentMethod!,
                                totalAmount: _finalPaymentAmount,
                                pointsEarned: pointsEarned, // Kirim poin yang didapat ke backend
                                cartItems: cartService.items, // Kirim semua item di keranjang
                                status: 'Completed',
                            );

                            if (response['success']) {
                                loyaltyService.addPointsFromPurchase(widget.totalPrice); // Frontend LoyaltyService update (opsional, bisa diganti fetch dari backend nanti)
                                cartService.clearCart(); // Bersihkan keranjang
                                snackBarMessage = 'Pembayaran berhasil! Anda mendapatkan ${formatNumberWithThousandsSeparator(pointsEarned.toDouble())} poin.';
                                snackBarColor = Colors.green;
                            } else {
                                snackBarMessage = response['message'] ?? 'Pembayaran gagal.';
                            }
                          }
                        } catch (e) {
                          snackBarMessage = 'Terjadi error saat mengirim pesanan: $e';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(snackBarMessage),
                            backgroundColor: snackBarColor,
                          ),
                        );

                        if (snackBarColor == Colors.green) { // Jika sukses, navigasi ke success screen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(loyaltyService.isRedeeming ? Icons.stars : Icons.credit_card, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Pay Now',
                            style: AppTextStyles.h4.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, String prefix = 'Rp', Color? valueColor}) {
    Color defaultColor = isTotal ? AppColors.primaryColor : AppColors.textColor;
    if (valueColor != null) {
      defaultColor = valueColor;
    }

    String amountText;
    if (amount == 0 && prefix == '') {
      amountText = '0 Point';
    } else if (prefix == '') { // Untuk poin
      amountText = '${formatNumberWithThousandsSeparator(amount)} Point';
    } else { // Untuk Rupiah
      amountText = formatRupiah(amount);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 10.0 : 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? AppColors.darkGrey : AppColors.textColor,
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String value,
    required String? groupValue,
    required String title,
    required String subtitle,
    String? logoAsset,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      color: AppColors.backgroundColor,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: AppColors.primaryColor,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4),
                    Text(subtitle, style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText)),
                  ],
                ),
              ),
              if (logoAsset != null) ...[
                const SizedBox(width: 10),
                Image.asset(
                  logoAsset,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}