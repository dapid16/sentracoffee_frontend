// lib/models/loyalty_history.dart

import 'dart:convert';

List<LoyaltyHistory> loyaltyHistoryFromJson(String str) =>
    List<LoyaltyHistory>.from(json.decode(str)["records"].map((x) => LoyaltyHistory.fromJson(x)));

class LoyaltyHistory {
  final int idPointHistory;
  final int pointsChange;
  final String type;
  final DateTime historyDate;
  final String? description;

  LoyaltyHistory({
    required this.idPointHistory,
    required this.pointsChange,
    required this.type,
    required this.historyDate,
    this.description,
  });

  factory LoyaltyHistory.fromJson(Map<String, dynamic> json) => LoyaltyHistory(
        idPointHistory: int.parse(json["id_point_history"].toString()),
        pointsChange: int.parse(json["points_change"].toString()),
        type: json["type"],
        historyDate: DateTime.parse(json["history_date"]),
        description: json["description"],
      );
}