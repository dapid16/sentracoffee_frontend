// lib/screens/admin/admin_dashboard_screen.dart (FINAL DENGAN SEMUA NAVIGASI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
// --- PERBAIKAN PATH IMPORT ---
import 'package:sentra_coffee_frontend/screens/manage_product_screen.dart';
import 'package:sentra_coffee_frontend/screens/employee_list_screen.dart';
import 'package:sentra_coffee_frontend/screens/new_transaction_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminAuthService = Provider.of<AdminAuthService>(context, listen: false);
    final ownerName = adminAuthService.currentOwner?.namaOwner ?? 'Admin';

    // Daftar halaman untuk IndexedStack (jika BottomNav mau ganti-ganti halaman)
    final List<Widget> _pages = [
      _buildDashboardContent(context),
      const Center(child: Text('Halaman Rewards Admin')), // Placeholder
      const Center(child: Text('Halaman Orders Admin')), // Placeholder
    ];

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
            const Text('Welcome!', style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text(
              'Admin $ownerName',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black, size: 28),
            onPressed: () {
              Provider.of<AdminAuthService>(context, listen: false).logout();
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

  Widget _buildDashboardContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAdminActionItem(
                  context,
                  Icons.inventory_2_outlined,
                  'Manage\nProduct',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProductScreen()));
                  },
                ),
                _buildAdminActionItem(
                  context, Icons.people_alt_outlined, 'List of\nEmployees',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeListScreen()));
                  },
                ),
                _buildAdminActionItem(context, Icons.store_outlined, 'Outlet', onTap: () { print("Outlet tapped"); }),
                _buildAdminActionItem(context, Icons.account_balance_wallet_outlined, 'Wallet', onTap: () { print("Wallet tapped"); }),
                _buildAdminActionItem(context, Icons.help_outline, 'Help', onTap: () { print("Help tapped"); }),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Laporan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReportCard('Penjualan Mei 2024', 'Rp100.000.000', '0,00% vs bulan lalu')),
                const SizedBox(width: 16),
                Expanded(child: _buildReportCard('Penjualan April 2024', 'Rp100.000.000', '0,00% vs bulan lalu')),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionItem(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

  Widget _buildReportCard(String title, String amount, String comparison) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(comparison, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
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
              // --- PERBAIKAN UTAMA DI SINI ---
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewTransactionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: 'Rewards'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}