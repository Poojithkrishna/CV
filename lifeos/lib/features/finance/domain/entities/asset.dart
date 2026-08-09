import 'package:flutter/foundation.dart';

import 'asset_type.dart';

@immutable
class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.currentValue = 0,
    this.purchasePrice,
    this.purchaseDate,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final AssetType type;
  final double currentValue;

  /// Reference only — not used in any calculation.
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final String? notes;
  final int colorValue;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Asset copyWith({
    String? name,
    AssetType? type,
    double? currentValue,
    double? purchasePrice,
    bool clearPurchasePrice = false,
    DateTime? purchaseDate,
    bool clearPurchaseDate = false,
    String? notes,
    bool clearNotes = false,
    int? colorValue,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      purchasePrice: clearPurchasePrice ? null : (purchasePrice ?? this.purchasePrice),
      purchaseDate: clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Asset && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
