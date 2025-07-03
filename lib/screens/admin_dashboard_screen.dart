import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/wallet_report.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/screens/manage_product_screen.dart';
import 'package:sentra_coffee_frontend/screens/employee_list_screen.dart';
import 'package:sentra_coffee_frontend/screens/new_transaction_screen.dart';
import 'package:sentra_coffee_frontend/screens/admin_wallet_screen.dart';
import 'package:sentra_coffee_frontend/screens/admin_manage_promotions_screen.dart';
import 'package:sentra_coffee_frontend/screens/admin_order_history_screen.dart';
import 'package:sentra_coffee_frontend/services/admin_order_service.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_DashboardHomePageState> _homePageKey = GlobalKey<_DashboardHomePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardHomePage(key: _homePageKey),
      const AdminOrderHistoryScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminAuthService =
        Provider.of<AdminAuthService>(context, listen: false);
    final ownerName = adminAuthService.currentOwner?.namaOwner ?? 'Admin';

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
              'Admin $ownerName',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.black, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: Colors.black, size: 28),
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
                  MaterialPageRoute(
                      builder: (context) => const NewTransactionScreen()),
                );
                if (mounted) {
                  // Memicu refresh data di kedua halaman setelah transaksi
                  Provider.of<AdminOrderService>(context, listen: false).fetchOrders();
                  _homePageKey.currentState?.refreshReports();
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

class _DashboardHomePage extends StatefulWidget {
  const _DashboardHomePage({Key? key}) : super(key: key);

  @override
  State<_DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<_DashboardHomePage> {
  late Future<List<WalletReport>> _reportsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _reportsFuture = _apiService.fetchWalletReports();
  }

  void refreshReports() {
    setState(() {
      _reportsFuture = _apiService.fetchWalletReports();
    });
  }

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
                _buildAdminActionItem(context, Icons.inventory_2_outlined,
                    'Manage\nProduct',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManageProductScreen()))),
                _buildAdminActionItem(context, Icons.people_alt_outlined,
                    'List of\nEmployees',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmployeeListScreen()))),
                _buildAdminActionItem(
                    context, Icons.account_balance_wallet_outlined, 'Wallet',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WalletScreen()))),
                _buildAdminActionItem(
                    context, Icons.campaign_outlined, 'Manage\nPromo',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminManagePromotionsScreen()))),
                _buildAdminActionItem(context, Icons.help_outline, 'Help',
                    onTap: () => print("Help tapped")),
              ],
            ),
            const SizedBox(height: 40),
            const Text('Laporan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            FutureBuilder<List<WalletReport>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Gagal memuat laporan: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("Belum ada laporan penjualan."));
                }

                final latestReports = snapshot.data!.take(2).toList();

                return Row(
                  children: List.generate(latestReports.length, (index) {
                    final report = latestReports[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: index == 0 ? 8.0 : 0,
                            left: index == 1 ? 8.0 : 0),
                        child: _buildReportCard(
                          report.monthName,
                          report.totalRevenue,
                          report.comparison,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionItem(BuildContext context, IconData icon, String label,
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

  Widget _buildReportCard(String title, String amount, String comparison) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(amount,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(comparison,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}