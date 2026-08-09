import 'package:flutter/foundation.dart';

@immutable
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.caloriesPerServing = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.servingLabel = 'serving',
    this.isArchived = false,
  });

  final String id;
  final String name;
  final double caloriesPerServing;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String servingLabel;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  FoodItem copyWith({
    String? name,
    double? caloriesPerServing,
    double? proteinG,
    double? carbsG,
    double? fatG,
    String? servingLabel,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      servingLabel: servingLabel ?? this.servingLabel,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is FoodItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
