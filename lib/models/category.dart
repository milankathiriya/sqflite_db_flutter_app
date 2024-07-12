import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class Category {
  int? id;
  final String name;
  Uint8List? image;

  Category({
    this.id,
    required this.name,
    this.image,
  });

  factory Category.fromMap({required Map<String, dynamic> data}) {
    return Category(
      id: data["id"],
      name: data["name"],
      image: data["image"],
    );
  }
}
