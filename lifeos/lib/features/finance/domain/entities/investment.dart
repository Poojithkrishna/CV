import 'package:flutter/foundation.dart';

import 'investment_type.dart';

@immutable
class Investment {
  const Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.investedAmount = 0,
    this.currentValue = 0,
    this.purchaseDate,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final InvestmentType type;
  final double investedAmount;
  final double currentValue;
  final DateTime? purchaseDate;
  final String? notes;
  final int colorValue;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get gainLoss => currentValue - investedAmount;

  double get gainLossPercent => investedAmount <= 0 ? 0 : (gainLoss / investedAmount) * 100;

  Investment copyWith({
    String? name,
    InvestmentType? type,
    double? investedAmount,
    double? currentValue,
    DateTime? purchaseDate,
    bool clearPurchaseDate = false,
    String? notes,
    bool clearNotes = false,
    int? colorValue,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      purchaseDate: clearPurchaseDate ? null : (purchaseDate ?? this.purchaseDate),
      notes: clearNotes ? null : (notes ?? this.notes),
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Investment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
