// lib/models/customer.dart (VERSI FINAL DENGAN PERBAIKAN)

class Customer {
  final int idCustomer;
  final String nama;
  final String email;
  final String? noHp;

  Customer({
    required this.idCustomer,
    required this.nama,
    required this.email,
    this.noHp,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      // --- PERBAIKAN #1: Samakan dengan kunci JSON dari backend ---
      idCustomer: json['id_customer'] as int,
      
      nama: json['nama'] as String,
      email: json['email'] as String,
      noHp: json['no_hp'] as String?, // Casting aman ke String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // --- PERBAIKAN #2: Samakan juga di sini untuk konsistensi ---
      'id_customer': idCustomer,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
    };
  }
}