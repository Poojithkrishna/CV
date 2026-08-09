import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/food_item.dart';

extension FoodItemRowMapper on FoodItemRow {
  FoodItem toDomain() {
    return FoodItem(
      id: id,
      name: name,
      caloriesPerServing: caloriesPerServing,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      servingLabel: servingLabel,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension FoodItemEntityMapper on FoodItem {
  FoodItemsCompanion toCompanion() {
    return FoodItemsCompanion.insert(
      id: id,
      name: name,
      caloriesPerServing: Value(caloriesPerServing),
      proteinG: Value(proteinG),
      carbsG: Value(carbsG),
      fatG: Value(fatG),
      servingLabel: Value(servingLabel),
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
