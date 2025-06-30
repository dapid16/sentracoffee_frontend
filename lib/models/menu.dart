// lib/models/menu.dart (VERSI FINAL DENGAN PERBAIKAN)

import 'dart:convert';

// Helper function ini tidak perlu diubah
List<Menu> menuFromJson(String str) =>
    List<Menu>.from(json.decode(str)["records"].map((x) => Menu.fromJson(x)));

class Menu {
  final int idMenu;
  final String namaMenu;
  final String kategori;
  final double harga;
  final bool isAvailable;
  final String? image; // Nama properti `image` di Dart kita pertahankan, bagus!

  Menu({
    required this.idMenu,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.isAvailable,
    this.image,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      idMenu: int.parse(json['id_menu'].toString()),
      namaMenu: json['nama_menu'],
      kategori: json['kategori'],
      harga: double.parse(json['harga'].toString()),
      // --- PERBAIKAN #1: Parsing 'is_available' lebih aman ---
      // Mengubah angka 1 atau string '1' menjadi true, selain itu false.
      isAvailable: json['is_available'] == 1 || json['is_available'] == '1',
      // --- PERBAIKAN #2: Ambil dari kunci 'gambar' di JSON ---
      // Data dari backend kuncinya 'gambar', kita simpan ke properti 'image' di Dart.
      image: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_menu": idMenu,
      "nama_menu": namaMenu,
      "kategori": kategori,
      "harga": harga,
      "is_available": isAvailable,
      "gambar": image, // Saat mengirim JSON, kita pakai kunci 'gambar'
    };
  }
}