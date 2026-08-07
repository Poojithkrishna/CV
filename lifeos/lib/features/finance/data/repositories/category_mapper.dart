import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_type.dart';

extension CategoryRowMapper on CategoryRow {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      type: CategoryType.values.byName(type),
      colorValue: colorValue,
      iconKey: iconKey,
      isArchived: isArchived,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CategoryEntityMapper on Category {
  CategoriesCompanion toCompanion() {
    return CategoriesCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      iconKey: Value(iconKey),
      colorValue: colorValue,
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
