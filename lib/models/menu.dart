// lib/models/menu.dart (VERSI GABUNGAN SEMUA MODEL)

import 'dart:convert';

//==================================================================
// MODEL UTAMA: MENU PRODUK (BUKU MENU)
//==================================================================
List<Menu> menuFromJson(String str) =>
    List<Menu>.from(json.decode(str)["records"].map((x) => Menu.fromJson(x)));

class Menu {
  final int idMenu;
  final String namaMenu;
  final String kategori;
  final double harga;
  final bool isAvailable;
  final String? image;

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
      isAvailable: json['is_available'] == 1 || json['is_available'] == '1',
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
      "gambar": image,
    };
  }
}


//==================================================================
// MODEL TAMBAHAN: UNTUK TRANSAKSI (CATETAN PESANAN)
// Model-model ini kita "nebeng" di file menu.dart biar nggak usah bikin file baru.
//==================================================================


// Model untuk item yang ada di keranjang/cart
class TransactionCartItem {
  final Menu menu;
  int quantity;
  final String size;
  final String ristretto;
  final String servingStyle;

  TransactionCartItem({
    required this.menu,
    required this.quantity,
    required this.size,
    required this.ristretto,
    required this.servingStyle,
  });
}


// Model untuk "jembatan" data yang dibawa dari ProductOptionsScreen
class CustomizedOrderItem {
  final Menu menu;
  final int quantity;
  final String ristretto;
  final String servingStyle;
  final String size;

  CustomizedOrderItem({
    required this.menu,
    required this.quantity,
    required this.ristretto,
    required this.servingStyle,
    required this.size,
  });
}