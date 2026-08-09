import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../tables/supplement_log_entries_table.dart';
import '../tables/supplements_table.dart';

part 'supplements_dao.g.dart';

final Uuid _uuid = Uuid();

/// Owns both Supplements and SupplementLogEntries: toggling whether a
/// supplement was taken on a given day is a read-then-write (does an
/// entry already exist for this supplement + day?) that has to happen
/// atomically, exactly like `HabitsDao.toggleChecklistItem`.
@DriftAccessor(tables: [Supplements, SupplementLogEntries])
class SupplementsDao extends DatabaseAccessor<AppDatabase> with _$SupplementsDaoMixin {
  SupplementsDao(super.db);

  // --- Supplements ---

  Stream<List<SupplementRow>> watchActiveSupplements() {
    return (select(supplements)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<SupplementRow?> watchSupplement(String id) {
    return (select(supplements)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertSupplement(SupplementsCompanion entry) {
    return into(supplements).insert(entry);
  }

  Future<bool> updateSupplement(SupplementsCompanion entry) {
    return update(supplements).replace(entry);
  }

  Future<int> deleteSupplement(String id) {
    return (delete(supplements)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Log entries ---

  Stream<SupplementLogEntryRow?> watchLogEntryForDate(String supplementId, DateTime date) {
    return (select(supplementLogEntries)
          ..where((tbl) => tbl.supplementId.equals(supplementId) & tbl.date.equals(date)))
        .watchSingleOrNull();
  }

  /// Flips whether [supplementId] was taken on [date], creating the entry
  /// (defaulting to taken) if this is the first toggle for that day.
  Future<void> toggleTaken(String supplementId, DateTime date) {
    return transaction(() async {
      final SupplementLogEntryRow? existing = await (select(supplementLogEntries)
            ..where((tbl) => tbl.supplementId.equals(supplementId) & tbl.date.equals(date)))
          .getSingleOrNull();
      if (existing == null) {
        await into(supplementLogEntries).insert(
          SupplementLogEntriesCompanion.insert(
            id: _uuid.v4(),
            supplementId: supplementId,
            date: date,
            taken: const Value(true),
            createdAt: DateTime.now(),
          ),
        );
      } else {
        await (update(supplementLogEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          SupplementLogEntriesCompanion(taken: Value(!existing.taken)),
        );
      }
    });
  }
}
