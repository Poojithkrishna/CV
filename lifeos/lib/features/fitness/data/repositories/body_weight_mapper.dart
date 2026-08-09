import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/body_weight_entry.dart';

extension BodyWeightEntryRowMapper on BodyWeightEntryRow {
  BodyWeightEntry toDomain() {
    return BodyWeightEntry(
      id: id,
      date: date,
      weightKg: weightKg,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension BodyWeightEntityMapper on BodyWeightEntry {
  BodyWeightEntriesCompanion toCompanion() {
    return BodyWeightEntriesCompanion.insert(
      id: id,
      date: date,
      weightKg: weightKg,
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
