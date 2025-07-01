// lib/screens/payment_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

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
  
  // --- State untuk halaman ini ---
  Customer? _selectedCustomer;
  String _selectedPaymentOption = 'Cash'; // Default payment
  bool _isProcessing = false;
  bool _isRedeemingPoints = false; // Toggle untuk redeem
  double _currentTotal = 0; // Total yang harus dibayar

  @override
  void initState() {
    super.initState();
    _customersFuture = _apiService.fetchAllCustomers();
    _currentTotal = widget.totalPrice; // Set total awal dari data keranjang
  }

  // Fungsi untuk hitung ulang total bayar
  void _recalculateTotal() {
    setState(() {
      // Jika redeem aktif, total jadi 0. Jika tidak, kembali ke harga asli.
      // Asumsi: Redeem poin membuat seluruh transaksi gratis.
      _currentTotal = _isRedeemingPoints ? 0.0 : widget.totalPrice;
    });
  }

  // Fungsi untuk memproses transaksi ke API
  void _processTransaction() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer.'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    // Validasi poin jika mode redeem aktif
    // Asumsi: Minimal 1000 poin untuk bisa redeem
    if (_isRedeemingPoints && _selectedCustomer!.points < 1000) { 
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poin customer tidak cukup untuk redeem.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final idStaff = 1; // Asumsi ID Staff/Kasir yang login
      final int? pointsToUse = _isRedeemingPoints ? 1000 : null; // Poin yang dikurangi

      final success = await _apiService.createTransaction(
        customerId: _selectedCustomer!.idCustomer,
        staffId: idStaff,
        paymentMethod: _isRedeemingPoints ? 'Points' : _selectedPaymentOption,
        totalAmount: _currentTotal, // Kirim total yang sudah disesuaikan
        items: widget.orderItems,
        pointsUsed: pointsToUse, // Kirim poin yang digunakan ke API
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction successful!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw Exception('Failed to create transaction on server.');
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
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
        title: const Text('Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  const Text('Total Price', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_currentTotal), 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Select Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) return const Text('Could not load customers.');
                
                return DropdownButtonFormField<Customer>(
                  decoration: InputDecoration(
                    hintText: 'Select a customer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: _selectedCustomer,
                  items: snapshot.data!.map((customer) => DropdownMenuItem<Customer>(
                    value: customer,
                    child: Text('${customer.nama} (${customer.points} pts)'), // Tampilkan poin customer
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomer = value;
                      _isRedeemingPoints = false; // Reset pilihan redeem setiap ganti customer
                      _recalculateTotal();
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            
            // --- Fitur Redeem Point ---
            if (_selectedCustomer != null) // Hanya tampil jika customer sudah dipilih
              _buildRedeemPointsTile(),

            const SizedBox(height: 12),
            
            // --- Opsi Pembayaran Lainnya ---
            // Hanya tampil jika tidak sedang mode redeem
            if (!_isRedeemingPoints) ...[
              const Text('Order payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isProcessing 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
            : const Text('Confirm Payment', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // Widget untuk menampilkan opsi redeem
  Widget _buildRedeemPointsTile() {
    // Asumsi minimal poin untuk redeem adalah 1000
    bool canRedeem = _selectedCustomer!.points >= 1000; 

    return SwitchListTile(
      title: const Text('Redeem Loyalty Points', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${_selectedCustomer!.points} points available. ' + (canRedeem ? 'Eligible to redeem.' : 'Not enough points.')),
      value: _isRedeemingPoints,
      onChanged: canRedeem ? (bool value) {
        setState(() {
          _isRedeemingPoints = value;
          _recalculateTotal(); // Hitung ulang total saat switch diubah
        });
      } : null, // Disable switch jika poin tidak cukup
      secondary: Icon(Icons.star, color: canRedeem ? Colors.amber : Colors.grey),
      tileColor: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      activeColor: Colors.green,
    );
  }

  // Widget untuk menampilkan opsi pembayaran biasa
  Widget _buildPaymentOptionTile({required String title, required String value}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentOption = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentOption == value ? Colors.blueAccent : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentOption,
              onChanged: (String? newValue) => setState(() => _selectedPaymentOption = newValue!),
              activeColor: Colors.blueAccent,
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}