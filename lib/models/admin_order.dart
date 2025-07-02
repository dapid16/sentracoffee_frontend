// lib/models/admin_order.dart

import 'dart:convert';

List<AdminOrder> adminOrderFromJson(String str) => List<AdminOrder>.from(json.decode(str)["records"].map((x) => AdminOrder.fromJson(x)));

class AdminOrder {
    final String idTransaction;
    final DateTime transactionDate;
    final String? customerName;
    final String? staffName;
    final String paymentMethod;
    final String totalAmount;
    final String? promoName;
    final String discountAmount;
    final List<Detail> details;

    AdminOrder({
        required this.idTransaction,
        required this.transactionDate,
        this.customerName,
        this.staffName,
        required this.paymentMethod,
        required this.totalAmount,
        this.promoName,
        required this.discountAmount,
        required this.details,
    });

    factory AdminOrder.fromJson(Map<String, dynamic> json) => AdminOrder(
        idTransaction: json["id_transaction"].toString(),
        transactionDate: DateTime.parse(json["transaction_date"]),
        customerName: json["customer_name"],
        staffName: json["staff_name"],
        paymentMethod: json["payment_method"],
        totalAmount: json["total_amount"],
        promoName: json["promo_name"],
        discountAmount: json["discount_amount"],
        details: List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
    );
}

class Detail {
    final int quantity;
    final String namaMenu;

    Detail({
        required this.quantity,
        required this.namaMenu,
    });

    factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        quantity: int.parse(json["quantity"].toString()),
        namaMenu: json["nama_menu"],
    );
}