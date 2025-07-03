// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/promotion.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/loyalty_point_screen.dart';
import 'package:sentra_coffee_frontend/screens/cart_screen.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/screens/order_history_screen.dart';
import 'package:sentra_coffee_frontend/screens/product_detail_screen.dart';
import 'package:sentra_coffee_frontend/services/order_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  late Future<List<Promotion>> _promoFuture;
  late Future<List<Menu>> _menuFuture;
  final ApiService apiService = ApiService();

  final String _imageBaseUrl = 'http://localhost/SentraCoffee/uploads/';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    _promoFuture = apiService.fetchActivePromotions();
    _menuFuture = apiService.fetchAvailableMenus();
  }

  void _startPromoAutoScroll(List<dynamic> items) {
    if (items.isEmpty) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % items.length;
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
      const LoyaltyPointScreen(),
      const OrderHistoryScreen(),
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
          IconButton(
            icon: const Icon(Icons.logout_outlined,
                color: AppColors.textColor, size: 28),
            onPressed: () {
              Provider.of<OrderService>(context, listen: false).clearOrders();
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Our Promo',
                style: AppTextStyles.h3.copyWith(color: AppColors.textColor)),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Promotion>>(
            future: _promoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text("Gagal memuat promo: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(
                    height: 180,
                    child: Center(child: Text("Tidak ada promo aktif.")));
              }

              final promos = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _startPromoAutoScroll(promos);
              });

              return Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: promos.length,
                      itemBuilder: (context, index) {
                        return _buildPromoCard(promos[index]);
                      },
                    ),
                  ),
                  if (promos.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: promos.length,
                          effect: WormEffect(
                            dotHeight: 8.0,
                            dotWidth: 8.0,
                            activeDotColor: AppColors.primaryColor,
                            dotColor: AppColors.greyText.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Our Menu',
                style: AppTextStyles.h3.copyWith(color: AppColors.textColor)),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Menu>>(
            future: _menuFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada menu tersedia.'));
              } else {
                final menuItems = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItemCard(menuItems[index]);
                  },
                );
              }
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Promotion promo) {
    String discountText = '';
    if (promo.discountType == 'persen') {
      final value = double.parse(promo.discountValue);
      discountText =
          "${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}% OFF";
    } else {
      final value = double.parse(promo.discountValue);
      discountText = "Potongan ${formatRupiah(value)}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.brown[400],
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promo.promoName,
              style: AppTextStyles.h3
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                promo.description,
                style: AppTextStyles.bodyText1
                    .copyWith(color: Colors.white.withOpacity(0.9)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                discountText,
                style: AppTextStyles.bodyText1
                    .copyWith(color: Colors.brown, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(Menu item) {
    final bool hasImage = item.image != null && item.image!.isNotEmpty;
    final String imageUrl = hasImage ? '$_imageBaseUrl${item.image}' : '';
    
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
        elevation: 4,
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
            Expanded(
              child: hasImage
                  ? Image.network(
                      imageUrl,
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
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.coffee,
                            size: 50, color: Colors.grey[400]),
                      ),
                    ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaMenu,
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(item.harga),
                    style: AppTextStyles.bodyText1.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}