import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/recovery_entry.dart';

extension RecoveryEntryRowMapper on RecoveryEntryRow {
  RecoveryEntry toDomain() {
    return RecoveryEntry(
      id: id,
      date: date,
      sleepHours: sleepHours,
      sorenessLevel: sorenessLevel,
      stressLevel: stressLevel,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension RecoveryEntityMapper on RecoveryEntry {
  RecoveryEntriesCompanion toCompanion() {
    return RecoveryEntriesCompanion.insert(
      id: id,
      date: date,
      sleepHours: Value(sleepHours),
      sorenessLevel: Value(sorenessLevel),
      stressLevel: Value(stressLevel),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
