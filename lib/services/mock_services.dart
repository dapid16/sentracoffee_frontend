// lib/services/mock_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/menu.dart';

class MockService {
  Future<List<Menu>> fetchMenus() async {
    // Baca isi file assets/mock_menus.json
    final String dataString =
        await rootBundle.loadString('assets/mock_menu.json');
    final Map<String, dynamic> jsonData = json.decode(dataString);

    // Ambil array "data" yang berisi daftar menu
    List<dynamic> daftar = jsonData['data'];
    // Ubah tiap elemen jadi objek Menu
    return daftar.map((item) => Menu.fromJson(item)).toList();
  }
}
