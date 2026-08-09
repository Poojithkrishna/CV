import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/supplement.dart';

extension SupplementRowMapper on SupplementRow {
  Supplement toDomain() {
    return Supplement(
      id: id,
      name: name,
      dosageLabel: dosageLabel,
      notes: notes,
      colorValue: colorValue,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension SupplementEntityMapper on Supplement {
  SupplementsCompanion toCompanion() {
    return SupplementsCompanion.insert(
      id: id,
      name: name,
      dosageLabel: Value(dosageLabel),
      notes: Value(notes),
      colorValue: colorValue,
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
