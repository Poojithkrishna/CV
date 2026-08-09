import 'package:flutter/foundation.dart';

/// Summed calories/macros across a set of `FoodLogEntry` rows — see
/// `NutritionStats.totalsFor`.
@immutable
class NutritionTotals {
  const NutritionTotals({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  NutritionTotals operator +(NutritionTotals other) {
    return NutritionTotals(
      calories: calories + other.calories,
      proteinG: proteinG + other.proteinG,
      carbsG: carbsG + other.carbsG,
      fatG: fatG + other.fatG,
    );
  }
}
