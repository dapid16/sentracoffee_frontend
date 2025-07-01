// lib/models/promotion.dart

import 'dart:convert';

List<Promotion> promotionFromJson(String str) => List<Promotion>.from(json.decode(str)["records"].map((x) => Promotion.fromJson(x)));

class Promotion {
    final int idPromotion;
    final String promoName;
    final String description;
    final String discountType;
    final String discountValue;
    final bool isActive;

    Promotion({
        required this.idPromotion,
        required this.promoName,
        required this.description,
        required this.discountType,
        required this.discountValue,
        required this.isActive,
    });

    factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        idPromotion: json["id_promotion"],
        promoName: json["promo_name"],
        description: json["description"],
        discountType: json["discount_type"],
        discountValue: json["discount_value"],
        isActive: json["is_active"],
    );

    Map<String, dynamic> toJson() => {
        "id_promotion": idPromotion,
        "promo_name": promoName,
        "description": description,
        "discount_type": discountType,
        "discount_value": discountValue,
        "is_active": isActive,
    };
}