import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../tables/habit_entries_table.dart';
import '../tables/habits_table.dart';

part 'habits_dao.g.dart';

final Uuid _uuid = Uuid();

/// Owns both Habits and HabitEntries: logging progress for a period is a
/// read-then-write (does an entry already exist for this habit + period?)
/// that has to happen atomically so two rapid taps can't create two rows
/// for the same period.
@DriftAccessor(tables: [Habits, HabitEntries])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  // --- Habits ---

  Stream<List<HabitRow>> watchActiveHabits() {
    return (select(habits)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<HabitRow?> watchHabit(String id) {
    return (select(habits)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertHabit(HabitsCompanion entry) {
    return into(habits).insert(entry);
  }

  Future<bool> updateHabit(HabitsCompanion entry) {
    return update(habits).replace(entry);
  }

  Future<int> deleteHabit(String id) {
    return (delete(habits)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Entries ---

  Stream<List<HabitEntryRow>> watchEntriesForHabit(String habitId) {
    return (select(habitEntries)..where((tbl) => tbl.habitId.equals(habitId))).watch();
  }

  Stream<HabitEntryRow?> watchEntryForPeriod(String habitId, DateTime periodStart) {
    return (select(habitEntries)
          ..where((tbl) => tbl.habitId.equals(habitId) & tbl.periodStart.equals(periodStart)))
        .watchSingleOrNull();
  }

  Future<HabitEntryRow?> _getEntryForPeriod(String habitId, DateTime periodStart) {
    return (select(habitEntries)
          ..where((tbl) => tbl.habitId.equals(habitId) & tbl.periodStart.equals(periodStart)))
        .getSingleOrNull();
  }

  /// Adds [delta] to the current period's progress, creating the entry if
  /// this is the first log for that period. [delta] may be negative (to
  /// undo a tap) but the result is floored at zero.
  Future<void> logProgress(String habitId, DateTime periodStart, double delta) {
    return transaction(() async {
      final HabitEntryRow? existing = await _getEntryForPeriod(habitId, periodStart);
      if (existing == null) {
        await into(habitEntries).insert(
          HabitEntriesCompanion.insert(
            id: _uuid.v4(),
            habitId: habitId,
            periodStart: periodStart,
            progressValue: Value(_flooredAtZero(delta)),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        final double next = _flooredAtZero(existing.progressValue + delta);
        await (update(habitEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          HabitEntriesCompanion(
            progressValue: Value(next),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Toggles [itemIndex] in the current period's checked-items set,
  /// creating the entry if needed.
  Future<void> toggleChecklistItem(String habitId, DateTime periodStart, int itemIndex) {
    return transaction(() async {
      final HabitEntryRow? existing = await _getEntryForPeriod(habitId, periodStart);
      final Set<int> current = existing == null
          ? <int>{}
          : _decodeIndices(existing.checkedItemIndices);

      final Set<int> next = Set.of(current);
      if (!next.remove(itemIndex)) {
        next.add(itemIndex);
      }
      final String encoded = next.isEmpty ? '' : next.join(',');

      if (existing == null) {
        await into(habitEntries).insert(
          HabitEntriesCompanion.insert(
            id: _uuid.v4(),
            habitId: habitId,
            periodStart: periodStart,
            checkedItemIndices: Value(encoded),
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await (update(habitEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          HabitEntriesCompanion(
            checkedItemIndices: Value(encoded),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Set<int> _decodeIndices(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    return raw.split(',').map(int.parse).toSet();
  }

  double _flooredAtZero(double value) => value < 0 ? 0 : value;
}
