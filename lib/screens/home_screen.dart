// lib/screens/home_screen.dart (VERSI FINAL)
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sentra_coffee_frontend/screens/product_detail_screen.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/loyalty_point_screen.dart';
import 'package:sentra_coffee_frontend/screens/cart_screen.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/screens/order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  // --- Constructor sekarang simpel, tidak butuh parameter ---
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  Timer? _timer;
  late Future<List<Menu>> _futureMenuItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    _futureMenuItems = ApiService().fetchAllMenu();
  }

  void _startPromoAutoScroll(List<Menu> promoItems) {
    if (promoItems.isEmpty) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % promoItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final String userName = authService.loggedInCustomer?.nama ?? 'Guest';

    final List<Widget> widgetOptions = [
      _buildHomeContent(),
      const LoyaltyPointScreen(), // Panggil tanpa parameter
      const OrderHistoryScreen(), // Panggil tanpa parameter
    ];

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome!',
                  style: AppTextStyles.bodyText2
                      .copyWith(color: AppColors.greyText)),
              Text(
                userName,
                style: AppTextStyles.h4.copyWith(color: AppColors.textColor),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.textColor, size: 28),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: AppColors.textColor, size: 28),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
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
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.greyText,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard_outlined, size: 28),
                label: 'Rewards',
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

  Widget _buildHomeContent() {
    return FutureBuilder<List<Menu>>(
      future: _futureMenuItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada menu tersedia.'));
        } else {
          final List<Menu> menuItems = snapshot.data!;
          final List<Menu> promoItems = menuItems.take(3).toList();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _startPromoAutoScroll(promoItems);
          });
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('Our Promo',
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.textColor)),
                ),
                const SizedBox(height: 16),
                promoItems.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: promoItems.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: _buildMenuItemCard(promoItems[index],
                                      isPromo: true),
                                );
                              },
                            ),
                          ),
                          if (promoItems.length > 1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: promoItems.length,
                                effect: WormEffect(
                                  dotHeight: 8.0,
                                  dotWidth: 8.0,
                                  activeDotColor: AppColors.primaryColor,
                                  dotColor:
                                      AppColors.greyText.withOpacity(0.5),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Center(
                        child: Text('No promo available',
                            style: AppTextStyles.bodyText1
                                .copyWith(color: AppColors.greyText)),
                      ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('Our Menu',
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.textColor)),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItemCard(menuItems[index]);
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildMenuItemCard(Menu item, {bool isPromo = false}) {
    final double hargaAsli = item.harga;
    final double hargaPromo = hargaAsli * 0.9; // Diskon 10% sementara

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: item.toJson()),
          ),
        );
      },
      child: Card(
        elevation: isPromo ? 8 : 4,
        color: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.lightGreyBackground,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 90.0,
              width: double.infinity,
              child: Image.asset(
                'assets/images/${item.namaMenu.toLowerCase().replaceAll(' ', '')}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.broken_image,
                          size: 50, color: Colors.grey[400]),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.namaMenu,
                      style: AppTextStyles.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPromo
                            ? AppColors.backgroundColor
                            : AppColors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatRupiah(hargaAsli),
                          style: AppTextStyles.bodyText2.copyWith(
                            color: AppColors.greyText,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRupiah(hargaPromo), // Solusi Sementara
                          style: AppTextStyles.bodyText1.copyWith(
                            color: Colors.green, // Solusi Sementara
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatRupiah(double amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}