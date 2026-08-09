import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';

extension MeasurementEntryRowMapper on MeasurementEntryRow {
  MeasurementEntry toDomain() {
    return MeasurementEntry(
      id: id,
      type: MeasurementType.values.byName(type),
      date: date,
      valueCm: valueCm,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MeasurementEntityMapper on MeasurementEntry {
  MeasurementEntriesCompanion toCompanion() {
    return MeasurementEntriesCompanion.insert(
      id: id,
      type: type.name,
      date: date,
      valueCm: valueCm,
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
