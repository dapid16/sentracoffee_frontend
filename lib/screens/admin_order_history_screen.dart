import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/admin_order.dart';
import 'package:sentra_coffee_frontend/services/admin_order_service.dart';

class AdminOrderHistoryScreen extends StatefulWidget {
  const AdminOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderHistoryScreen> createState() => _AdminOrderHistoryScreenState();
}

class _AdminOrderHistoryScreenState extends State<AdminOrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminOrderService>(context, listen: false).fetchOrders();
    });
  }

  Future<void> _refreshOrders() async {
    await Provider.of<AdminOrderService>(context, listen: false).fetchOrders();
  }

  String _formatRupiah(String amount) {
    final number = double.tryParse(amount) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrderService>(
      builder: (context, orderService, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refreshOrders,
            child: Builder(
              builder: (context) {
                if (orderService.isLoading && orderService.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (orderService.errorMessage != null) {
                  return Center(child: Text("Error: ${orderService.errorMessage}"));
                }
                if (orderService.orders.isEmpty) {
                  return const Center(child: Text("Tidak ada riwayat transaksi."));
                }
                
                final orders = orderService.orders;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(AdminOrder order) {
    String servedBy;
    IconData servedByIcon;
    
    // Logika untuk menentukan siapa yang memproses transaksi
    if (order.staffName != null && order.staffName != 'radja') {
      servedBy = "Oleh Staff: ${order.staffName}";
      servedByIcon = Icons.person_outline;
    } else if (order.staffName == 'radja') {
      servedBy = "Pesanan Mandiri (Online)";
      servedByIcon = Icons.phone_android;
    } else {
      servedBy = "Oleh: Owner";
      servedByIcon = Icons.shield_outlined;
    }
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${order.idTransaction}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('d MMM y, HH:mm').format(order.transactionDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.account_circle_outlined, "Customer: ${order.customerName ?? 'N/A'}"),
            const SizedBox(height: 4),
            _buildInfoRow(servedByIcon, servedBy),
            const SizedBox(height: 12),
            ...order.details.map((detail) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4),
              child: Text("• ${detail.quantity}x ${detail.namaMenu}"),
            )).toList(),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentChip(order.paymentMethod),
                    if (order.promoName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Promo: ${order.promoName}", style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                Text(
                  _formatRupiah(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
  
  Widget _buildPaymentChip(String paymentMethod) {
    Color chipColor;
    switch (paymentMethod.toLowerCase()) {
      case 'cash': chipColor = Colors.green; break;
      case 'qris': chipColor = Colors.blue; break;
      case 'credit_card': chipColor = Colors.orange; break;
      case 'dana': chipColor = Colors.lightBlue; break;
      case 'points': chipColor = Colors.amber; break;
      default: chipColor = Colors.grey;
    }

    return Chip(
      label: Text(paymentMethod.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}