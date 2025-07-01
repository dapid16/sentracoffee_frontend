// lib/screens/admin_manage_promotions_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/promotion.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/screens/admin_add_promotion_screen.dart';

class AdminManagePromotionsScreen extends StatefulWidget {
  const AdminManagePromotionsScreen({Key? key}) : super(key: key);

  @override
  State<AdminManagePromotionsScreen> createState() =>
      _AdminManagePromotionsScreenState();
}

class _AdminManagePromotionsScreenState
    extends State<AdminManagePromotionsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Promotion>> _promosFuture;

  @override
  void initState() {
    super.initState();
    _loadPromos();
  }

  void _loadPromos() {
    setState(() {
      _promosFuture = _apiService.fetchAllPromotions();
    });
  }

  Future<void> _togglePromoStatus(Promotion promo) async {
    bool success = await _apiService.updatePromotionStatus(
      id: promo.idPromotion,
      isActive: !promo.isActive,
    );
    if (success) {
      _loadPromos();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal mengubah status promo'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Promo'),
      ),
      body: FutureBuilder<List<Promotion>>(
        future: _promosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada promo."));
          }

          final promos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadPromos(),
            child: ListView.builder(
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final promo = promos[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(promo.promoName),
                    subtitle: Text(promo.description),
                    trailing: Switch(
                      value: promo.isActive,
                      onChanged: (value) {
                        _togglePromoStatus(promo);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminAddPromotionScreen()),
          );
          if (result == true) {
            _loadPromos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}