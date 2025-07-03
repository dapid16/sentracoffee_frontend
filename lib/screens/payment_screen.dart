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
  final int redeemCost = 25000;

  final _promoController = TextEditingController();
  String? _appliedPromoName;
  String? _promoMessage;
  double _discountAmount = 0.0;
  bool _isApplyingPromo = false;

  String _selectedPaymentMethod = 'dana';
  bool _isLoading = false;
  bool _isRedeemingPoints = false;

  double get _finalTotal {
    if (_isRedeemingPoints) return 0;
    final totalAfterDiscount = widget.totalPrice - _discountAmount;
    return totalAfterDiscount < 0 ? 0 : totalAfterDiscount;
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() async {
    if (_promoController.text.isEmpty || _isApplyingPromo) return;

    if (_isRedeemingPoints) {
      setState(() {
        _isRedeemingPoints = false;
      });
    }

    setState(() { _isApplyingPromo = true; });

    final apiService = ApiService();
    final response = await apiService.validatePromoCode(
      promoName: _promoController.text,
      totalPrice: widget.totalPrice,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      setState(() {
        _discountAmount = (response['discount_amount'] as num).toDouble();
        _appliedPromoName = _promoController.text;
        _promoMessage = "Promo '${response['promo_name']}' berhasil diterapkan!";
      });
    } else {
      setState(() {
        _promoMessage = response['message'] ?? 'Nama promo tidak valid.';
        _discountAmount = 0;
        _appliedPromoName = null;
      });
    }
    setState(() { _isApplyingPromo = false; });
  }

  void _processPayment() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = ApiService();

    if (authService.loggedInCustomer == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Anda harus login.')));
      return;
    }

    if (_isRedeemingPoints && authService.loggedInCustomer!.points < redeemCost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Poin tidak cukup untuk redeem.'),
          backgroundColor: Colors.red));
      return;
    }
    
    if (_isRedeemingPoints && cartService.items.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Redeem poin hanya berlaku untuk pembelian 1 item.'),
          backgroundColor: Colors.orange,
        ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<TransactionCartItem> transactionItems =
          cartService.items.map((cartItem) {
        Menu tempMenu = Menu(
          idMenu: cartItem.idMenu,
          namaMenu: cartItem.name,
          harga: cartItem.pricePerItem,
          kategori: '',
          isAvailable: true,
          image: cartItem.image,
        );
        return TransactionCartItem(
          menu: tempMenu,
          quantity: cartItem.quantity,
          size: cartItem.customizations,
          ristretto: 'one',
          servingStyle: 'onsite',
        );
      }).toList();

      final success = await apiService.createTransaction(
        customerId: authService.loggedInCustomer!.idCustomer,
        staffId: 1, // Asumsi ID Staff default untuk transaksi online
        paymentMethod: _isRedeemingPoints ? 'Points' : _selectedPaymentMethod,
        totalAmount: _finalTotal,
        items: transactionItems,
        pointsUsed: _isRedeemingPoints ? redeemCost : null,
        promoName: _isRedeemingPoints ? null : _appliedPromoName,
      );

      if (!mounted) return;

      if (success) {
        await authService.refreshLoggedInCustomerData();
        cartService.clearCart();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
          (route) => route.isFirst,
        );
      } else {
        throw Exception('Gagal memproses transaksi di server.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final cartService = Provider.of<CartService>(context);
    final customerPoints = authService.loggedInCustomer?.points ?? 0;
    
    bool canRedeem = customerPoints >= redeemCost;

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreyBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Payment',
            style: AppTextStyles.h4.copyWith(color: AppColors.darkGrey)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 220),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
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
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.shopping_cart_outlined,
                              color: AppColors.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                authService.loggedInCustomer?.nama ?? 'Customer',
                                style: AppTextStyles.h4),
                            Text('Sentra Coffee Store',
                                style: AppTextStyles.bodyText1
                                    .copyWith(color: AppColors.darkGrey)),
                            Text('Seturan',
                                style: AppTextStyles.bodyText2
                                    .copyWith(color: AppColors.greyText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Detail Pesanan',
                    style:
                        AppTextStyles.h4.copyWith(color: AppColors.textColor)),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  color: AppColors.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', widget.totalPrice),
                        if (_discountAmount > 0)
                          _buildSummaryRow(
                              'Diskon (${_appliedPromoName ?? ''})', -_discountAmount,
                              valueColor: Colors.green),
                        if (_isRedeemingPoints)
                          _buildSummaryRow(
                              'Redeem Poin', -redeemCost.toDouble(),
                              valueColor: Colors.green, usePoints: true),
                        const Divider(height: 20, thickness: 1),
                        _buildSummaryRow('Total Bayar', _finalTotal,
                            isTotal: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Punya Promo?',
                    style:
                        AppTextStyles.h4.copyWith(color: AppColors.textColor)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        enabled: !_isRedeemingPoints,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama promo',
                          border: const OutlineInputBorder(),
                          filled: _isRedeemingPoints,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          if (_appliedPromoName != null) {
                            setState(() {
                              _discountAmount = 0;
                              _appliedPromoName = null;
                              _promoMessage = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isApplyingPromo
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                            ),
                            onPressed: _isRedeemingPoints ? null : _applyPromo,
                            child: const Text('Apply'),
                          ),
                  ],
                ),
                if (_promoMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_promoMessage!,
                        style: TextStyle(
                            color: _discountAmount > 0
                                ? Colors.green
                                : Colors.red)),
                  ),
                const SizedBox(height: 20),
                Text('Pilih Metode Pembayaran',
                    style:
                        AppTextStyles.h4.copyWith(color: AppColors.textColor)),
                const SizedBox(height: 10),
                if (!_isRedeemingPoints) ...[
                  _buildPaymentOption(context,
                      value: 'dana',
                      groupValue: _selectedPaymentMethod,
                      title: 'Online payment',
                      subtitle: 'Dana',
                      logoAsset: 'assets/images/logo_dana.png',
                      onChanged: (value) =>
                          setState(() => _selectedPaymentMethod = value!)),
                  const SizedBox(height: 10),
                  _buildPaymentOption(context,
                      value: 'credit_card',
                      groupValue: _selectedPaymentMethod,
                      title: 'Credit Card',
                      subtitle: '2540 xxxx xxxx 2648',
                      logoAsset: 'assets/images/logo_visa_mastercard.png',
                      onChanged: (value) =>
                          setState(() => _selectedPaymentMethod = value!)),
                  const SizedBox(height: 10),
                ],
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  tileColor: AppColors.backgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  title: const Text('Gunakan Poin'),
                  subtitle: Text('Butuh $redeemCost Poin. ' +
                      (canRedeem ? 'Poin Anda cukup.' : 'Poin tidak cukup.')),
                  value: _isRedeemingPoints,
                  onChanged: canRedeem
                      ? (value) {
                          if (value) {
                            if (cartService.items.length > 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Redeem poin hanya berlaku untuk pembelian 1 item.'),
                                    backgroundColor: Colors.orange),
                              );
                              return;
                            }
                          }
                          setState(() {
                            _isRedeemingPoints = value;
                            _selectedPaymentMethod = value ? 'Points' : 'dana';
                            if (value) {
                              _discountAmount = 0;
                              _appliedPromoName = null;
                              _promoMessage = null;
                              _promoController.clear();
                            }
                          });
                        }
                      : null,
                  secondary: Icon(Icons.star,
                      color: canRedeem ? Colors.amber : Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3))
                  ]),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Bayar Sekarang (${formatRupiah(_finalTotal)})',
                          style:
                              AppTextStyles.h4.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, Color? valueColor, bool usePoints = false}) {
    final num displayAmount = usePoints ? amount.abs() : amount;
    String amountText = usePoints
        ? '${formatNumberWithThousandsSeparator(displayAmount.toDouble())} Pts'
        : formatRupiah(amount);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? 8.0 : 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 18 : 16,
                  color:
                      isTotal ? AppColors.darkGrey : AppColors.textColor)),
          Text(amountText,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 18 : 16,
                  color: valueColor ??
                      (isTotal
                          ? AppColors.primaryColor
                          : AppColors.textColor))),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context,
      {required String value,
      required String? groupValue,
      required String title,
      required String subtitle,
      String? logoAsset,
      required ValueChanged<String?> onChanged}) {
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
              Radio<String>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  activeColor: AppColors.primaryColor),
              const SizedBox(width: 5),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title, style: AppTextStyles.h4),
                    Text(subtitle,
                        style: AppTextStyles.bodyText2
                            .copyWith(color: AppColors.greyText)),
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