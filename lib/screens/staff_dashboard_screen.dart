import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/services/staff_auth_service.dart';
import 'package:sentra_coffee_frontend/screens/manage_product_screen.dart';
import 'package:sentra_coffee_frontend/screens/new_transaction_screen.dart';
import 'package:sentra_coffee_frontend/screens/admin_manage_promotions_screen.dart';
import 'package:sentra_coffee_frontend/screens/admin_order_history_screen.dart';
import 'package:sentra_coffee_frontend/services/admin_order_service.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _selectedIndex = 0;

  // Daftar halaman untuk bottom navigation bar
  final List<Widget> _pages = [
    const _StaffDashboardHomePage(), // Widget untuk konten utama
    const AdminOrderHistoryScreen(), // Halaman riwayat transaksi yang sama dengan admin
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffAuthService = Provider.of<StaffAuthService>(context, listen: false);
    final staffName = staffAuthService.currentStaff?.namaStaff ?? 'Staff';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome!',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text(
              staffName,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: Colors.black, size: 28),
            onPressed: () {
              Provider.of<StaffAuthService>(context, listen: false).logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomSection(context),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewTransactionScreen()),
                );
                // Setelah kembali, refresh data riwayat
                if (mounted) {
                  Provider.of<AdminOrderService>(context, listen: false).fetchOrders();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Transaction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey[600],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.storefront_outlined), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget terpisah untuk konten utama dashboard staff
class _StaffDashboardHomePage extends StatelessWidget {
  const _StaffDashboardHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
              children: [
                _buildActionItem(
                    context, Icons.inventory_2_outlined, 'Manage\nProduct',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageProductScreen()))),
                _buildActionItem(
                    context, Icons.campaign_outlined, 'Manage\nPromo',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminManagePromotionsScreen()))),
                _buildActionItem(context, Icons.help_outline, 'Help',
                    onTap: () => print("Help tapped")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}