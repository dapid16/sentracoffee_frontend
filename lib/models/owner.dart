// lib/models/owner.dart

class Owner {
  final int idOwner;
  final String namaOwner;
  final String email;

  Owner({
    required this.idOwner,
    required this.namaOwner,
    required this.email,
  });

  // Factory constructor untuk membuat objek Owner dari JSON
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      idOwner: json['id_owner'],
      namaOwner: json['nama_owner'],
      email: json['email'],
    );
  }
}