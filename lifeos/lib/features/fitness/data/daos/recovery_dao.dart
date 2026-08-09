import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/recovery_entries_table.dart';

part 'recovery_dao.g.dart';

@DriftAccessor(tables: [RecoveryEntries])
class RecoveryDao extends DatabaseAccessor<AppDatabase> with _$RecoveryDaoMixin {
  RecoveryDao(super.db);

  Stream<List<RecoveryEntryRow>> watchAllEntries() {
    return (select(recoveryEntries)..orderBy([(tbl) => OrderingTerm.asc(tbl.date)])).watch();
  }

  Stream<RecoveryEntryRow?> watchEntryForDate(DateTime date) {
    return (select(recoveryEntries)..where((tbl) => tbl.date.equals(date))).watchSingleOrNull();
  }

  /// Inserts a new entry, or — if [entry]'s date already has one —
  /// updates that existing row instead (using its own id), so logging
  /// twice in one day overwrites rather than duplicating.
  Future<void> upsertForDate(RecoveryEntriesCompanion entry) {
    return transaction(() async {
      final RecoveryEntryRow? existing = await (select(recoveryEntries)
            ..where((tbl) => tbl.date.equals(entry.date.value)))
          .getSingleOrNull();
      if (existing == null) {
        await into(recoveryEntries).insert(entry);
      } else {
        await (update(recoveryEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          RecoveryEntriesCompanion(
            sleepHours: entry.sleepHours,
            sorenessLevel: entry.sorenessLevel,
            stressLevel: entry.stressLevel,
            notes: entry.notes,
            updatedAt: entry.updatedAt,
          ),
        );
      }
    });
  }

  Future<int> deleteEntry(String id) {
    return (delete(recoveryEntries)..where((tbl) => tbl.id.equals(id))).go();
  }
}
