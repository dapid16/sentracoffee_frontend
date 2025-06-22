// lib/screens/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:sentra_coffee_frontend/services/order_service.dart'; // Import OrderService
import 'package:sentra_coffee_frontend/models/order.dart'; // Import Order Model
import 'package:sentra_coffee_frontend/screens/home_screen.dart'; // Untuk navigasi BottomNav
// Import CartScreen jika ingin navigasi ke CartScreen dari BottomNav
// import 'package:sentra_coffee_frontend/screens/cart_screen.dart';


class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // PENTING: Minta OrderService untuk fetch data saat screen pertama kali dibuka
    Provider.of<OrderService>(context, listen: false).fetchOrders(userName: widget.userName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'My order',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'On going'),
            Tab(text: 'History'),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.brown,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          if (orderService.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (orderService.errorMessage != null)
            Center(child: Text('Error: ${orderService.errorMessage}'))
          else
            _buildOrderList(orderService.onGoingOrders),

          if (orderService.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (orderService.errorMessage != null)
            Center(child: Text('Error: ${orderService.errorMessage}'))
          else
            _buildOrderList(orderService.historyOrders),
        ],
      ),

      // ==============================================================
      // PERBAIKAN DI SINI: Bottom Navigation Bar
      // ==============================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _tabController.index,
            onTap: (index) {
              setState(() {
                _tabController.index = index;
              });
              // Logika navigasi ke screen lain
              if (index == 0) { // Home tab
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              } else if (index == 1) { // Promo / Gift tab
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PromoScreen()));
              } else if (index == 2) { // Orders tab (sudah di OrderHistoryScreen)
                // Tidak perlu navigasi karena sudah di halaman ini
              }
            },
            selectedItemColor: Colors.brown,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false, // <<< PERBAIKAN DI SINI! Hapus 'child:'
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard_outlined, size: 28),
                label: 'Promo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined, size: 28),
                label: 'Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // Helper Widget untuk Daftar Pesanan (On going / History)
  // ==============================================================
  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet!'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal & Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.dateTime,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Rp${order.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Daftar Item dalam Pesanan ini
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (order.items).map((item) { // Pastikan order.items adalah List
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 18, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            item.itemName,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      order.location,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}