// lib/models/customer.dart

class Customer {
  final int idCustomer;
  final String nama;
  final String email;
  final String? noHp; // Bisa null karena opsional di backend

  Customer({
    required this.idCustomer,
    required this.nama,
    required this.email,
    this.noHp,
  });

  // Factory constructor untuk membuat objek Customer dari JSON respons backend
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      idCustomer: json['customer_id'] as int, // Sesuaikan dengan key 'customer_id' dari respons login.php
      nama: json['nama'] as String,
      email: json['email'] as String,
      noHp: json['no_hp'] != null ? json['no_hp'] as String : null,
    );
  }

  // Method untuk mengonversi objek Customer ke Map (jika perlu disimpan di Shared Preferences)
  Map<String, dynamic> toJson() {
    return {
      'customer_id': idCustomer,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
    };
  }
}