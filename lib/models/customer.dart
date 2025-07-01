// lib/models/customer.dart

import 'dart:convert';

class Customer {
  final int idCustomer;
  final String nama;
  final String email;
  final String? noHp;
  final int points;

  Customer({
    required this.idCustomer,
    required this.nama,
    required this.email,
    this.noHp,
    this.points = 0, // <<< Dibuat opsional dengan nilai default 0
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '') ?? 0,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'],
      // <<< Dibuat lebih aman dengan tryParse
      points: int.tryParse(json['points']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_customer': idCustomer,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'points': points, // Ini sudah benar
    };
  }
}