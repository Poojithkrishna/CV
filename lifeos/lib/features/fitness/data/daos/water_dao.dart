import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../tables/water_entries_table.dart';
import '../tables/water_goal_table.dart';

part 'water_dao.g.dart';

final Uuid _uuid = Uuid();

@DriftAccessor(tables: [WaterEntries, WaterGoals])
class WaterDao extends DatabaseAccessor<AppDatabase> with _$WaterDaoMixin {
  WaterDao(super.db);

  // --- Entries ---

  Stream<WaterEntryRow?> watchEntryForDate(DateTime date) {
    return (select(waterEntries)..where((tbl) => tbl.date.equals(date))).watchSingleOrNull();
  }

  Stream<List<WaterEntryRow>> watchEntriesBetween(DateTime from, DateTime to) {
    return (select(waterEntries)
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(from) & tbl.date.isSmallerOrEqualValue(to))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
        .watch();
  }

  /// Adds [deltaMl] to the day's running total, creating the row if this
  /// is the first log for that day. [deltaMl] may be negative (to undo a
  /// tap) but the result is floored at zero.
  Future<void> logWater(DateTime date, int deltaMl) {
    return transaction(() async {
      final WaterEntryRow? existing =
          await (select(waterEntries)..where((tbl) => tbl.date.equals(date))).getSingleOrNull();
      final DateTime now = DateTime.now();
      if (existing == null) {
        await into(waterEntries).insert(
          WaterEntriesCompanion.insert(
            id: _uuid.v4(),
            date: date,
            amountMl: Value(_flooredAtZero(deltaMl)),
            updatedAt: now,
          ),
        );
      } else {
        final int next = _flooredAtZero(existing.amountMl + deltaMl);
        await (update(waterEntries)..where((tbl) => tbl.id.equals(existing.id))).write(
          WaterEntriesCompanion(amountMl: Value(next), updatedAt: Value(now)),
        );
      }
    });
  }

  int _flooredAtZero(int value) => value < 0 ? 0 : value;

  // --- Goal ---

  Stream<WaterGoalRow?> watchGoal() {
    return (select(waterGoals)..where((tbl) => tbl.id.equals(kDefaultWaterGoalId)))
        .watchSingleOrNull();
  }

  Future<void> updateGoal(int dailyGoalMl) {
    return into(waterGoals).insertOnConflictUpdate(
      WaterGoalsCompanion.insert(
        id: kDefaultWaterGoalId,
        dailyGoalMl: Value(dailyGoalMl),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
