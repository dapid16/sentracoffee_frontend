import 'dart:convert';

List<MenuComposition> menuCompositionFromJson(String str) => List<MenuComposition>.from(json.decode(str)["records"].map((x) => MenuComposition.fromJson(x)));

class MenuComposition {
  int? idRawMaterial;
  String? namaBahan;
  String? unit;
  double quantityNeeded;

  MenuComposition({
    this.idRawMaterial,
    this.namaBahan,
    this.unit,
    required this.quantityNeeded,
  });

  factory MenuComposition.fromJson(Map<String, dynamic> json) => MenuComposition(
        idRawMaterial: json["id_raw_material"],
        namaBahan: json["nama_bahan"],
        unit: json["unit"],
        // <<< PERBAIKAN DI SINI >>>
        quantityNeeded: double.parse(json["quantity_needed"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id_raw_material": idRawMaterial,
        "quantity_needed": quantityNeeded,
      };
}