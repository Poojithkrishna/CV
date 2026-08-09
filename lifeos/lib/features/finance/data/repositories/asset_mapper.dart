import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';

extension AssetRowMapper on AssetRow {
  Asset toDomain() {
    return Asset(
      id: id,
      name: name,
      type: AssetType.values.byName(type),
      currentValue: currentValue,
      purchasePrice: purchasePrice,
      purchaseDate: purchaseDate,
      notes: notes,
      colorValue: colorValue,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension AssetEntityMapper on Asset {
  AssetsCompanion toCompanion() {
    return AssetsCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      currentValue: Value(currentValue),
      purchasePrice: Value(purchasePrice),
      purchaseDate: Value(purchaseDate),
      notes: Value(notes),
      colorValue: colorValue,
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
