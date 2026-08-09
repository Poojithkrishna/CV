import 'package:flutter/foundation.dart';

@immutable
class NutritionGoal {
  const NutritionGoal({
    required this.dailyCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.updatedAt,
  });

  final double dailyCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final DateTime updatedAt;

  NutritionGoal copyWith({
    double? dailyCalories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    DateTime? updatedAt,
  }) {
    return NutritionGoal(
      dailyCalories: dailyCalories ?? this.dailyCalories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
