// lib/models/raw_material.dart
import 'dart:convert';

List<RawMaterial> rawMaterialFromJson(String str) => List<RawMaterial>.from(json.decode(str)["records"].map((x) => RawMaterial.fromJson(x)));

class RawMaterial {
    final int idRawMaterial;
    final String namaBahan;
    double currentStock;
    final String unit;
    final double minStockLevel;

    RawMaterial({
        required this.idRawMaterial,
        required this.namaBahan,
        required this.currentStock,
        required this.unit,
        required this.minStockLevel,
    });

    factory RawMaterial.fromJson(Map<String, dynamic> json) => RawMaterial(
        idRawMaterial: json["id_raw_material"],
        namaBahan: json["nama_bahan"],
        currentStock: json["current_stock"],
        unit: json["unit"],
        minStockLevel: json["min_stock_level"],
    );
}