import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/services/staff_auth_service.dart';

class PaymentAdminScreen extends StatefulWidget {
  final List<TransactionCartItem> orderItems;
  final double totalPrice;

  const PaymentAdminScreen({
    Key? key,
    required this.orderItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<PaymentAdminScreen> createState() => _PaymentAdminScreenState();
}

class _PaymentAdminScreenState extends State<PaymentAdminScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Customer>> _customersFuture;

  // State untuk Poin & Promo
  final int redeemCost = 25000;
  final _promoController = TextEditingController();
  String? _appliedPromoName;
  String? _promoMessage;
  double _discountAmount = 0.0;
  bool _isApplyingPromo = false;

  // State lainnya
  Customer? _selectedCustomer;
  String _selectedPaymentOption = 'Cash';
  bool _isProcessing = false;
  bool _isRedeemingPoints = false;

  double get _finalTotal {
    if (_isRedeemingPoints) return 0.0;
    final totalAfterDiscount = widget.totalPrice - _discountAmount;
    return totalAfterDiscount < 0 ? 0 : totalAfterDiscount;
  }

  @override
  void initState() {
    super.initState();
    _customersFuture = _apiService.fetchAllCustomers();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() async {
    if (_promoController.text.isEmpty ||
        _isApplyingPromo ||
        _selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih customer dan masukkan nama promo terlebih dahulu.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    if (_isRedeemingPoints) {
      setState(() {
        _isRedeemingPoints = false;
      });
    }

    setState(() => _isApplyingPromo = true);

    final response = await _apiService.validatePromoCode(
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
    setState(() => _isApplyingPromo = false);
  }

  void _processTransaction() async {
    final staffAuth = Provider.of<StaffAuthService>(context, listen: false);
    final adminAuth = Provider.of<AdminAuthService>(context, listen: false);
    int? transactionStaffId;

    if (staffAuth.isLoggedIn) {
      transactionStaffId = staffAuth.currentStaff?.idStaff;
    } else if (adminAuth.isAdminLoggedIn) {
      transactionStaffId = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Anda harus login sebagai Admin atau Staff.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih customer terlebih dahulu.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (_isRedeemingPoints && _selectedCustomer!.points < redeemCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Poin customer tidak cukup untuk redeem.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final int? pointsToUse = _isRedeemingPoints ? redeemCost : null;

      final success = await _apiService.createTransaction(
        customerId: _selectedCustomer!.idCustomer,
        staffId: transactionStaffId,
        paymentMethod: _isRedeemingPoints ? 'Points' : _selectedPaymentOption,
        totalAmount: _finalTotal,
        items: widget.orderItems,
        pointsUsed: pointsToUse,
        promoName: _isRedeemingPoints ? null : _appliedPromoName,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Transaksi berhasil!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw Exception('Gagal membuat transaksi di server.');
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text('Total Price',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                      NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(_finalTotal),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold)),
                  if (_discountAmount > 0)
                    Text(
                      'Asli: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.totalPrice)}',
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Select Customer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty)
                  return const Text('Tidak dapat memuat data customer.');

                return DropdownButtonFormField<Customer>(
                  decoration: InputDecoration(
                    hintText: 'Pilih customer',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  value: _selectedCustomer,
                  items: snapshot.data!
                      .map((customer) => DropdownMenuItem<Customer>(
                            value: customer,
                            child: Text('${customer.nama} (${customer.points} pts)'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomer = value;
                      _isRedeemingPoints = false;
                      _promoController.clear();
                      _appliedPromoName = null;
                      _promoMessage = null;
                      _discountAmount = 0.0;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            if (_selectedCustomer != null) _buildRedeemPointsTile(),
            const SizedBox(height: 24),
            const Text('Punya Promo?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isApplyingPromo
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
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
                        color:
                            _discountAmount > 0 ? Colors.green : Colors.red)),
              ),
            const SizedBox(height: 24),
            if (!_isRedeemingPoints) ...[
              const Text('Order payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildPaymentOptionTile(title: 'Cash', value: 'Cash'),
              const SizedBox(height: 12),
              _buildPaymentOptionTile(title: 'QRIS', value: 'QRIS'),
              const SizedBox(height: 12),
              _buildPaymentOptionTile(title: 'Debit Card', value: 'Debit Card'),
            ]
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: (_isProcessing) ? null : _processTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : const Text('Confirm Payment', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildRedeemPointsTile() {
    bool canRedeem = _selectedCustomer!.points >= redeemCost;

    return SwitchListTile(
      title: const Text('Redeem Loyalty Points',
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          '${_selectedCustomer!.points} points available. Requires $redeemCost points.'),
      value: _isRedeemingPoints,
      onChanged: canRedeem
          ? (bool value) {
              setState(() {
                _isRedeemingPoints = value;
                if (value) {
                  _discountAmount = 0;
                  _appliedPromoName = null;
                  _promoMessage = null;
                  _promoController.clear();
                }
              });
            }
          : null,
      secondary: Icon(Icons.star, color: canRedeem ? Colors.amber : Colors.grey),
      tileColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      activeColor: Colors.green,
    );
  }

  Widget _buildPaymentOptionTile({required String title, required String value}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentOption = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentOption == value
                ? Colors.blueAccent
                : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentOption,
              onChanged: (String? newValue) =>
                  setState(() => _selectedPaymentOption = newValue!),
              activeColor: Colors.blueAccent,
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}