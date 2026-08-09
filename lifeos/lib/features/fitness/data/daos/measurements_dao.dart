import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/measurement_entries_table.dart';

part 'measurements_dao.g.dart';

@DriftAccessor(tables: [MeasurementEntries])
class MeasurementsDao extends DatabaseAccessor<AppDatabase> with _$MeasurementsDaoMixin {
  MeasurementsDao(super.db);

  Stream<List<MeasurementEntryRow>> watchEntriesForType(String type) {
    return (select(measurementEntries)
          ..where((tbl) => tbl.type.equals(type))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
        .watch();
  }

  /// Every entry across every type, most recent first — the repository
  /// derives "latest value per type" from this client-side, same as
  /// `habitsWeeklyCompletionProvider` combines per-habit streams.
  Stream<List<MeasurementEntryRow>> watchAllEntries() {
    return (select(measurementEntries)..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])).watch();
  }

  /// Inserts a new entry, or — if this [entry]'s type+date already has
  /// one — updates that existing row instead, so re-logging the same
  /// body part on the same day overwrites rather than duplicating.
  Future<void> upsertForTypeAndDate(MeasurementEntriesCompanion entry) {
    return transaction(() async {
      final MeasurementEntryRow? existing = await (select(measurementEntries)
            ..where((tbl) => tbl.type.equals(entry.type.value) & tbl.date.equals(entry.date.value)))
          .getSingleOrNull();
      if (existing == null) {
        await into(measurementEntries).insert(entry);
      } else {
        await (update(measurementEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          MeasurementEntriesCompanion(
            valueCm: entry.valueCm,
            notes: entry.notes,
            updatedAt: entry.updatedAt,
          ),
        );
      }
    });
  }

  Future<int> deleteEntry(String id) {
    return (delete(measurementEntries)..where((tbl) => tbl.id.equals(id))).go();
  }
}
