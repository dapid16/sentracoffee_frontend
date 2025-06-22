// lib/models/menu.dart

class Menu {
  final int idMenu;
  final String namaMenu;
  final String kategori;
  final double
      harga; // Ini adalah harga dari backend, kita akan anggap ini harga asli
  final bool isAvailable;
  String? image; // Opsional, jika nanti ada field image dari backend

  Menu({
    required this.idMenu,
    required this.namaMenu,
    required this.kategori,
    required this.harga,
    required this.isAvailable,
    this.image,
  });

  // Factory constructor untuk membuat objek Menu dari JSON
  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      idMenu:  json['id_menu'] as int,
      namaMenu: json['nama_menu'] as String,
      kategori: json['kategori'] as String,
      // Penting: harga dari backend adalah String ("25000.00"), jadi harus diconvert ke double
      harga: double.parse(json['harga'].toString()),
      isAvailable: json['is_available'] as bool,
      // image: json['image'] != null ? json['image'] as String : null,
    );
  }

  // Method to convert Menu object to JSON
  // UBAH: Jangan ubah harga ke String lagi di sini!
  Map<String, dynamic> toJson() {
    return {
      'id_menu': idMenu,
      'nama_menu': namaMenu,
      'kategori': kategori,
      // HAPUS .toStringAsFixed(2)! Biarkan tetap double
      'harga': harga, // <-- PERBAIKAN DI SINI!
      'is_available': isAvailable,
      'image': image,
    };
  }
}
