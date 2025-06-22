// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sentra_coffee_frontend/screens/product_detail_screen.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart'; // Import AppColors
import 'package:sentra_coffee_frontend/utils/text_styles.dart'; // Import AppTextStyles
import 'package:sentra_coffee_frontend/screens/loyalty_point_screen.dart'; // Import LoyaltyPointScreen
import 'package:sentra_coffee_frontend/screens/cart_screen.dart'; // Import CartScreen
import 'package:sentra_coffee_frontend/services/api_service.dart'; // Import ApiService
import 'package:sentra_coffee_frontend/models/menu.dart'; // Import Menu model
import 'package:sentra_coffee_frontend/screens/order_history_screen.dart'; // Import OrderHistoryScreen

class HomeScreen extends StatefulWidget {
  final String userName; // Terima userName

  const HomeScreen({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late PageController _pageController;
  Timer? _timer; // UBAH: Jadikan _timer nullable, tidak lagi 'late'

  late List<Widget> _widgetOptions; // Ini akan berisi semua screen untuk IndexedStack

  Future<List<Menu>> _futureMenuItems = ApiService().fetchAllMenu();

  List<Menu> _promoItems = [];
  List<Menu> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );

    // Inisialisasi _widgetOptions di sini setelah widget.userName tersedia
    _widgetOptions = <Widget>[
      _buildHomeContent(), // Konten utama Home
      LoyaltyPointScreen(username: widget.userName), // Teruskan userName
      OrderHistoryScreen(userName: widget.userName), // Teruskan userName
    ];
  }

  // Fungsi ini sudah tidak terlalu dibutuhkan karena _futureMenuItems diinisialisasi langsung
  // Tapi bisa dipakai untuk refresh manual jika perlu
  void _fetchMenuItems() {
    setState(() {
      _futureMenuItems = ApiService().fetchAllMenu();
      _promoItems = []; // Kosongkan agar terisi ulang dari FutureBuilder
      _menuItems = []; // Kosongkan agar terisi ulang dari FutureBuilder
      _timer?.cancel(); // Cancel timer lama jika ada
    });
  }

  void _startPromoAutoScroll() {
    _timer?.cancel(); // Pastikan timer sebelumnya dibatalkan

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_promoItems.isNotEmpty && _pageController.hasClients && _pageController.position.haveDimensions) {
        int nextPage = (_pageController.page!.toInt() + 1);
        if (nextPage >= _promoItems.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else if (_promoItems.isEmpty) {
        _timer?.cancel(); // Batalkan timer jika tidak ada promo
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
    // Tidak ada Navigator.pushReplacement di sini karena IndexedStack mengganti konten di body
    // Jika ada BottomNavigationBarItem yang navigasi ke halaman terpisah (bukan bagian dari IndexedStack)
    // baru gunakan Navigator.push/pushReplacement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
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
                widget.userName, // Tampilkan userName dari widget
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
              print('Cart icon tapped!');
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person_outline,
                color: AppColors.textColor, size: 28),
            onPressed: () {
              print('Profile icon tapped!');
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      // Konten utama berubah berdasarkan selectedIndex
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
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
            onTap: _onItemTapped, // Panggil _onItemTapped untuk mengubah index
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

  // === _buildHomeContent: Konten asli dari Home Screen ===
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
          _menuItems = snapshot.data!;
          _promoItems = _menuItems.take(2).toList();

          if (_promoItems.isNotEmpty && (_timer == null || !_timer!.isActive)) {
            _startPromoAutoScroll();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Our Promo',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textColor),
                  ),
                ),
                const SizedBox(height: 16),
                _promoItems.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _promoItems.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: _buildMenuItemCard(_promoItems[index], isPromo: true),
                                );
                              },
                            ),
                          ),
                          if (_promoItems.length > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: _promoItems.length,
                                effect: WormEffect(
                                  dotHeight: 8.0,
                                  dotWidth: 8.0,
                                  activeDotColor: AppColors.primaryColor,
                                  dotColor: AppColors.greyText.withOpacity(0.5),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Center(
                        child: Text(
                          'No promo available',
                          style: AppTextStyles.bodyText1.copyWith(color: AppColors.greyText),
                        ),
                      ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Our Menu',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textColor),
                  ),
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
                    childAspectRatio: 0.95, // Disesuaikan untuk card yang rapi
                  ),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItemCard(_menuItems[index]);
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

  // Helper function untuk Card Menu Item
  Widget _buildMenuItemCard(Menu item, {bool isPromo = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: item.toJson()),
          ),
        );
        print('Navigating to product detail for: ${item.namaMenu}');
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
              height: 90.0, // Tinggi area gambar
              width: double.infinity,
              child: Image.asset(
                'assets/images/${item.namaMenu.toLowerCase().replaceAll(' ', '')}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                    ),
                  );
                },
              ),
            ),
            Expanded( // Penting untuk mendorong teks ke bawah
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, // Mendorong teks ke bawah
                  children: [
                    Text(
                      item.namaMenu,
                      style: AppTextStyles.bodyText1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPromo ? AppColors.backgroundColor : AppColors.textColor, // Teks putih untuk promo
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatRupiah(item.harga),
                          style: AppTextStyles.bodyText2.copyWith(
                            color: isPromo ? AppColors.greyText : AppColors.greyText, // Warna abu-abu untuk harga
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatRupiah(item.hargaPromo), // Asumsi ada harga promo
                          style: AppTextStyles.bodyText1.copyWith(
                            color: AppColors.accentColor, // Warna hijau untuk harga promo
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

  // Helper untuk format rupiah (pastikan ada di utils/constants.dart)
  String formatRupiah(double amount) {
    return 'Rp${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}