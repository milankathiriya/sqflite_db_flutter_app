import 'package:flutter/foundation.dart';

class IE {
  int? id;
  final String desc;
  final double amount;
  final int category;
  final String type;

  IE({
    this.id,
    required this.desc,
    required this.amount,
    required this.category,
    required this.type,
  });

  factory IE.fromMap({required Map<String, dynamic> data}) {
    return IE(
      id: data["id"],
      desc: data["desc"],
      amount: data["amount"],
      category: data["category"],
      type: data["type"],
    );
  }
}
