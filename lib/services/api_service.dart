import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/staff.dart';
import 'package:sentra_coffee_frontend/models/wallet_report.dart';
import 'package:sentra_coffee_frontend/models/loyalty_history.dart';
import 'package:sentra_coffee_frontend/models/promotion.dart';
import 'package:sentra_coffee_frontend/models/admin_order.dart';
import 'package:sentra_coffee_frontend/models/raw_material.dart';
import 'package:sentra_coffee_frontend/models/menu_composition.dart';

class ApiService {
  final String baseUrl = "http://localhost/SentraCoffee/api";

  Future<List<Menu>> fetchAllMenusForAdmin() async {
    final response = await http.get(Uri.parse('$baseUrl/menu/read.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('records') && responseData['records'] is List) {
        List<dynamic> menuJson = responseData['records'];
        return menuJson.map((json) => Menu.fromJson(json)).toList();
      }
    }
    throw Exception('Gagal memuat semua menu. Status Code: ${response.statusCode}');
  }

  Future<List<Menu>> fetchAvailableMenus() async {
    final response = await http.get(Uri.parse('$baseUrl/menu/read_available.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('records') && responseData['records'] is List) {
        List<dynamic> menuJson = responseData['records'];
        return menuJson.map((json) => Menu.fromJson(json)).toList();
      }
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Gagal memuat menu tersedia. Status Code: ${response.statusCode}');
  }

  Future<bool> createMenu(Menu menu, List<MenuComposition> compositions) async {
    var data = menu.toJson();
    data['compositions'] = compositions.map((c) => c.toJson()).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/menu/create.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(data),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateMenu(Menu menu, List<MenuComposition> compositions) async {
    var data = menu.toJson();
    data['compositions'] = compositions.map((c) => c.toJson()).toList();
    
    final response = await http.post(
      Uri.parse('$baseUrl/menu/update_menu.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['status'] == 'success';
    }
    return false;
  }
  
  Future<List<MenuComposition>> getMenuComposition(int menuId) async {
    final response = await http.get(Uri.parse('$baseUrl/menu/get_composition.php?id_menu=$menuId'));
    if (response.statusCode == 200) {
      return menuCompositionFromJson(response.body);
    } else {
      return [];
    }
  }

  Future<String?> uploadImage(Uint8List imageBytes, String filename) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/menu/upload_image.php'));
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: filename));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        return responseData['filename'];
      }
    }
    return null;
  }

  Future<bool> deleteMenu(int idMenu) async {
    final url = Uri.parse('$baseUrl/menu/delete.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'id_menu': idMenu}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error connecting to server on deleteMenu: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> registerUser(String nama, String email, String password, String? noHp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nama': nama, 'email': email, 'password': password, 'no_hp': noHp}),
    );
    return json.decode(response.body);
  }

  Future<List<Customer>> fetchAllCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customer/read.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('records') && data['records'] is List) {
        return (data['records'] as List).map((json) => Customer.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load customers');
  }

  Future<Customer?> fetchOneCustomer(int customerId) async {
    final response = await http.get(Uri.parse('$baseUrl/customer/read_single.php?id=$customerId'));
    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<Map<String, dynamic>> unifiedLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return json.decode(response.body);
  }

  Future<List<Staff>> fetchAllStaff() async {
    final response = await http.get(Uri.parse('$baseUrl/staff/read.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('records') && data['records'] is List) {
        return (data['records'] as List)
            .map((json) => Staff.fromJson(json))
            .toList();
      }
    }
    throw Exception('Failed to load staff');
  }

  Future<bool> createStaff({ required String namaStaff, required String email, required String password, required String role, String? noHp, required int idOwner, }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama_staff': namaStaff, 'email': email, 'password': password, 'role': role, 'no_hp': noHp, 'id_owner': idOwner,
      }),
    );
    return response.statusCode == 201;
  }
  
  Future<bool> deleteStaff(int idStaff) async {
    final response = await http.post(
      Uri.parse('$baseUrl/staff/delete.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'id_staff': idStaff}),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['status'] == 'success';
    }
    return false;
  }

  Future<bool> createTransaction({
    required int customerId,
    int? staffId,
    required String paymentMethod,
    required double totalAmount,
    required List<TransactionCartItem> items,
    int? pointsUsed,
    String? promoName,
  }) async {
    try {
      List<Map<String, dynamic>> itemsJson = items.map((item) {
        double basePrice = item.menu.harga;
        double sizeMultiplier = 1.0;
        if (item.size.toLowerCase().contains('small')) {
          sizeMultiplier = 0.8;
        } else if (item.size.toLowerCase().contains('large')) {
          sizeMultiplier = 1.2;
        }
        double finalPricePerItem = basePrice * sizeMultiplier;

        return {
          'id_menu': item.menu.idMenu,
          'quantity': item.quantity,
          'subtotal': finalPricePerItem * item.quantity,
        };
      }).toList();

      Map<String, dynamic> requestBody = {
        'id_customer': customerId,
        'staffId': staffId,
        'payment_method': paymentMethod,
        'total_amount': totalAmount,
        'details': itemsJson,
      };
      
      if (pointsUsed != null) { requestBody['points_used'] = pointsUsed; }
      if (promoName != null && promoName.isNotEmpty) { requestBody['promo_name'] = promoName; }

      final response = await http.post(
        Uri.parse('$baseUrl/transaction/create.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error in createTransaction: $e');
      return false;
    }
  }
  
  Future<List<WalletReport>> fetchWalletReports() async {
    final response = await http.get(Uri.parse('$baseUrl/report/wallet.php'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['reports'] is List) {
        return responseData['reports'].map<WalletReport>((json) => WalletReport.fromJson(json)).toList();
      }
    }
    throw Exception('Gagal memuat laporan wallet.');
  }

  Future<List<LoyaltyHistory>> fetchLoyaltyHistory(int customerId) async {
    final response = await http.get(Uri.parse('$baseUrl/customer/loyalty_history.php?id_customer=$customerId'));
    if (response.statusCode == 200) {
      return loyaltyHistoryFromJson(response.body);
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Gagal memuat riwayat poin');
  }
  
  Future<List<AdminOrder>> fetchAllTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transaction/read_all.php'));
    if (response.statusCode == 200) {
      return adminOrderFromJson(response.body);
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to load all transactions');
  }

  Future<List<Promotion>> fetchAllPromotions() async {
    final response = await http.get(Uri.parse('$baseUrl/promotion/read.php'));
    if (response.statusCode == 200) {
      return promotionFromJson(response.body);
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to load promotions');
  }

  Future<List<Promotion>> fetchActivePromotions() async {
    final response = await http.get(Uri.parse('$baseUrl/promotion/read_active.php'));
    if (response.statusCode == 200) {
      return promotionFromJson(response.body);
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to load active promotions');
  }

  Future<bool> createPromotion({ required String name, required String description, required String discountType, required double discountValue, }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/promotion/create.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, dynamic>{
        'promo_name': name, 'description': description, 'discount_type': discountType, 'discount_value': discountValue,
      }),
    );
    return response.statusCode == 201;
  }
  
  Future<bool> updatePromotionStatus({required int id, required bool isActive}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/promotion/update_status.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'id_promotion': id,
          'is_active': isActive,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error in updatePromotionStatus: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>> validatePromoCode({
    required String promoName,
    required double totalPrice,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/promotion/validate.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, dynamic>{
        'promo_name': promoName,
        'total_price': totalPrice,
      }),
    );
    return json.decode(response.body);
  }

  Future<List<RawMaterial>> fetchRawMaterials() async {
    final response = await http.get(Uri.parse('$baseUrl/stock/read.php'));
    if (response.statusCode == 200) {
      return rawMaterialFromJson(response.body);
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load raw materials');
    }
  }

  Future<bool> updateRawMaterialStock({
    required int id,
    required double newStock,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stock/update.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, dynamic>{
        'id_raw_material': id,
        'current_stock': newStock,
      }),
    );
    return response.statusCode == 200;
  }
  
  Future<bool> createRawMaterial({ required String name, required String unit, required double initialStock, required double minStock, }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stock/create.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, dynamic>{
        'nama_bahan': name,
        'unit': unit,
        'current_stock': initialStock,
        'min_stock_level': minStock,
      }),
    );
    return response.statusCode == 201;
  }
}