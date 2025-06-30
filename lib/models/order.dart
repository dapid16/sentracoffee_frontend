// lib/models/order.dart (VERSI FINAL v2 - PARSING LEBIH PINTAR)

import 'dart:convert';

List<Order> orderFromJson(String str) =>
    List<Order>.from(json.decode(str)["records"].map((x) => Order.fromJson(x)));

class TransactionDetail {
  final String namaMenu;
  final int quantity;
  final String subtotal;

  TransactionDetail({
    required this.namaMenu,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      namaMenu: json["nama_menu"],
      // --- DIBUAT LEBIH AMAN ---
      // Ubah dulu ke String, baru di-parse ke int, untuk menghindari error jika datanya String atau int
      quantity: int.parse(json["quantity"].toString()),
      subtotal: json["subtotal"],
    );
  }
}

class Order {
  final String idTransaction;
  final String transactionDate;
  final String paymentMethod;
  final String totalAmount;
  final String pointsEarned;
  final String status;
  final List<TransactionDetail> details;

  Order({
    required this.idTransaction,
    required this.transactionDate,
    required this.paymentMethod,
    required this.totalAmount,
    required this.pointsEarned,
    required this.status,
    required this.details,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<TransactionDetail> parsedDetails =
        detailsList.map((i) => TransactionDetail.fromJson(i)).toList();

    return Order(
      // --- DIBUAT LEBIH AMAN DENGAN .toString() ---
      // Apapun tipe datanya dari backend (int atau String), akan diubah jadi String di Dart.
      idTransaction: json["id_transaction"].toString(),
      transactionDate: json["transaction_date"].toString(),
      paymentMethod: json["payment_method"].toString(),
      totalAmount: json["total_amount"].toString(),
      pointsEarned: json["points_earned"].toString(),
      status: json["status"].toString(),
      details: parsedDetails,
    );
  }
}
