import 'package:flutter/foundation.dart';

import 'category_type.dart';

@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.iconKey,
    this.isArchived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final CategoryType type;
  final int colorValue;
  final String? iconKey;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category copyWith({
    String? name,
    CategoryType? type,
    int? colorValue,
    String? iconKey,
    bool clearIconKey = false,
    bool? isArchived,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      iconKey: clearIconKey ? null : (iconKey ?? this.iconKey),
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
