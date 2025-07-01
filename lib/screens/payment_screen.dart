// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/payment_success_screen.dart';
import 'package:sentra_coffee_frontend/models/cart.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';


// Helper Function untuk format Angka
String formatNumberWithThousandsSeparator(double amount) {
  final formatCurrency = NumberFormat.decimalPattern('id_ID');
  return formatCurrency.format(amount);
}

class PaymentScreen extends StatefulWidget {
  final double totalPrice;
  const PaymentScreen({Key? key, required this.totalPrice}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'dana';
  bool _isLoading = false;
  bool _isRedeemingPoints = false;
  double _currentTotal = 0;

  @override
  void initState() {
    super.initState();
    _currentTotal = widget.totalPrice;
  }

  void _recalculateTotal(bool isRedeeming) {
    setState(() {
      _isRedeemingPoints = isRedeeming;
      _currentTotal = _isRedeemingPoints ? 0.0 : widget.totalPrice;
      _selectedPaymentMethod = _isRedeemingPoints ? 'Points' : 'dana';
    });
  }

  void _processPayment() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = ApiService();

    if (!authService.isLoggedIn || authService.loggedInCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda harus login.')));
      return;
    }
    final currentCustomer = authService.loggedInCustomer!;
    
    if (_isRedeemingPoints && currentCustomer.points < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poin tidak cukup untuk redeem.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- PERBAIKAN FINAL ADA DI SINI ---
      List<TransactionCartItem> transactionItems = cartService.items.map((cartItem) {
        Menu tempMenu = Menu(
          idMenu: cartItem.idMenu,
          namaMenu: cartItem.name,
          harga: cartItem.pricePerItem,
          kategori: '',
          isAvailable: true,
          image: cartItem.image,
        );
        // Tambahkan parameter yang hilang sesuai error
        return TransactionCartItem(
          menu: tempMenu,
          quantity: cartItem.quantity,
          // Asumsikan nilai-nilai ini ada di CartItem atau diberi nilai default
          size: cartItem.customizations, 
          ristretto: 'one',              
          servingStyle: 'onsite',        
        );
      }).toList();
      // --- BATAS PERBAIKAN ---

      final int? pointsToUse = _isRedeemingPoints ? 1000 : null;

      final success = await apiService.createTransaction(
        customerId: currentCustomer.idCustomer,
        staffId: 1,
        paymentMethod: _selectedPaymentMethod,
        totalAmount: _currentTotal,
        items: transactionItems,
        pointsUsed: pointsToUse,
      );

      if (!mounted) return;

      if (success) {
        await authService.refreshLoggedInCustomerData();
        cartService.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil!'), backgroundColor: Colors.green));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
          (route) => route.isFirst,
        );
      } else {
        throw Exception('Gagal memproses transaksi di server.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final customerPoints = authService.loggedInCustomer?.points ?? 0;
    bool canRedeem = customerPoints >= 1000;

    double displayedAmount = _isRedeemingPoints ? 0 : widget.totalPrice;
    double displayedFinalAmount = _isRedeemingPoints ? 0 : widget.totalPrice;
    String amountPrefix = _isRedeemingPoints ? '' : 'Rp ';
    String totalPricePrefix = _isRedeemingPoints ? '' : 'Rp ';
    Color totalPriceColor = _isRedeemingPoints ? AppColors.textColor : AppColors.primaryColor;

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('My order', style: AppTextStyles.h4.copyWith(color: AppColors.darkGrey)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order payment', style: AppTextStyles.h2.copyWith(color: AppColors.textColor)),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.lightGreyBackground, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.shopping_cart_outlined, color: AppColors.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(authService.loggedInCustomer?.nama ?? 'Customer', style: AppTextStyles.h4),
                            Text('Magic Coffee store', style: AppTextStyles.bodyText1.copyWith(color: AppColors.darkGrey)),
                            Text('Seturan', style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Detail Pesanan', style: AppTextStyles.h4.copyWith(color: AppColors.textColor)),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                Text('Pilih Metode Pembayaran', style: AppTextStyles.h4.copyWith(color: AppColors.textColor)),
                const SizedBox(height: 10),
                if (!_isRedeemingPoints) ...[
                  _buildPaymentOption(context, value: 'dana', groupValue: _selectedPaymentMethod, title: 'Online payment', subtitle: 'Dana', logoAsset: 'assets/images/logo_dana.png', onChanged: (value) => setState(() => _selectedPaymentMethod = value!)),
                  const SizedBox(height: 10),
                  _buildPaymentOption(context, value: 'credit_card', groupValue: _selectedPaymentMethod, title: 'Credit Card', subtitle: '2540 xxxx xxxx 2648', logoAsset: 'assets/images/logo_visa_mastercard.png', onChanged: (value) => setState(() => _selectedPaymentMethod = value!)),
                  const SizedBox(height: 10),
                ],
                SwitchListTile(
                  title: const Text('Gunakan Poin'),
                  subtitle: Text('$customerPoints Pts tersedia. ' + (canRedeem ? 'Bisa redeem.' : 'Poin tidak cukup.')),
                  value: _isRedeemingPoints,
                  onChanged: canRedeem ? (value) {
                    _recalculateTotal(value);
                  } : null,
                  tileColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  secondary: Icon(Icons.star, color: canRedeem ? Colors.amber : Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Amount', style: AppTextStyles.bodyText1.copyWith(color: AppColors.darkGrey)),
                    Text('${amountPrefix}${formatNumberWithThousandsSeparator(displayedAmount)}', style: AppTextStyles.h4.copyWith(color: AppColors.textColor)),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total Price', style: AppTextStyles.bodyText1.copyWith(color: AppColors.darkGrey)),
                    Text('${totalPricePrefix}${formatNumberWithThousandsSeparator(displayedFinalAmount)}', style: AppTextStyles.h2.copyWith(color: totalPriceColor)),
                  ]),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isRedeemingPoints ? Icons.stars : Icons.credit_card, size: 24),
                          const SizedBox(width: 10),
                          Text('Pay Now', style: AppTextStyles.h4.copyWith(color: Colors.white)),
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

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, String prefix = 'Rp ', Color? valueColor}) {
    String amountText;
     if (amount == 0 && prefix == '') amountText = '0 Pts';
    else if (prefix != 'Rp ') amountText = '${formatNumberWithThousandsSeparator(amount)} Pts';
    else amountText = formatRupiah(amount);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 10.0 : 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 16, color: isTotal ? AppColors.darkGrey : AppColors.textColor)),
          Text(amountText, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 16, color: valueColor ?? (isTotal ? AppColors.primaryColor : AppColors.textColor))),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, {required String value, required String? groupValue, required String title, required String subtitle, String? logoAsset, required ValueChanged<String?> onChanged}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: AppColors.backgroundColor,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Row(
            children: [
              Radio<String>(value: value, groupValue: groupValue, onChanged: onChanged, activeColor: AppColors.primaryColor),
              const SizedBox(width: 5),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTextStyles.h4),
                Text(subtitle, style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText)),
              ])),
              if (logoAsset != null) ...[
                const SizedBox(width: 10),
                Image.asset(logoAsset, height: 30, fit: BoxFit.contain),
              ],
            ],
          ),
        ),
      ),
    );
  }
}