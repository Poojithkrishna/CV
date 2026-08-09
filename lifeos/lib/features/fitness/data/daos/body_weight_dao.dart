import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/body_weight_entries_table.dart';

part 'body_weight_dao.g.dart';

@DriftAccessor(tables: [BodyWeightEntries])
class BodyWeightDao extends DatabaseAccessor<AppDatabase> with _$BodyWeightDaoMixin {
  BodyWeightDao(super.db);

  Stream<List<BodyWeightEntryRow>> watchAllEntries() {
    return (select(bodyWeightEntries)..orderBy([(tbl) => OrderingTerm.asc(tbl.date)])).watch();
  }

  Stream<BodyWeightEntryRow?> watchEntryForDate(DateTime date) {
    return (select(bodyWeightEntries)..where((tbl) => tbl.date.equals(date))).watchSingleOrNull();
  }

  /// Inserts a new entry, or — if [entry]'s date already has one — updates
  /// that existing row instead (using its own id), so logging twice in one
  /// day overwrites rather than duplicating.
  Future<void> upsertForDate(BodyWeightEntriesCompanion entry) {
    return transaction(() async {
      final BodyWeightEntryRow? existing = await (select(bodyWeightEntries)
            ..where((tbl) => tbl.date.equals(entry.date.value)))
          .getSingleOrNull();
      if (existing == null) {
        await into(bodyWeightEntries).insert(entry);
      } else {
        await (update(bodyWeightEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          BodyWeightEntriesCompanion(
            weightKg: entry.weightKg,
            notes: entry.notes,
            updatedAt: entry.updatedAt,
          ),
        );
      }
    });
  }

  Future<int> deleteEntry(String id) {
    return (delete(bodyWeightEntries)..where((tbl) => tbl.id.equals(id))).go();
  }
}
