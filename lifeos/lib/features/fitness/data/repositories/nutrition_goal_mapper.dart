import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../tables/nutrition_goal_table.dart';

extension NutritionGoalRowMapper on NutritionGoalRow {
  NutritionGoal toDomain() {
    return NutritionGoal(
      dailyCalories: dailyCalories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      updatedAt: updatedAt,
    );
  }
}

extension NutritionGoalEntityMapper on NutritionGoal {
  NutritionGoalsCompanion toCompanion() {
    return NutritionGoalsCompanion.insert(
      id: kDefaultNutritionGoalId,
      dailyCalories: Value(dailyCalories),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      updatedAt: updatedAt,
    );
  }
}
