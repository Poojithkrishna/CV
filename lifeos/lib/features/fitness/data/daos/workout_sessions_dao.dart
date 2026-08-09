import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/logged_sets_table.dart';
import '../tables/workout_sessions_table.dart';

part 'workout_sessions_dao.g.dart';

/// Owns both WorkoutSessions and LoggedSets: logging a set has to check
/// the exercise's historical max weight (across every session) to decide
/// whether it's a new PR, and that check has to happen atomically with
/// the insert so two concurrent logs can never both claim the PR.
@DriftAccessor(tables: [WorkoutSessions, LoggedSets])
class WorkoutSessionsDao extends DatabaseAccessor<AppDatabase> with _$WorkoutSessionsDaoMixin {
  WorkoutSessionsDao(super.db);

  // --- Sessions ---

  Stream<List<WorkoutSessionRow>> watchRecentSessions({int limit = 20}) {
    return (select(workoutSessions)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)])
          ..limit(limit))
        .watch();
  }

  Stream<WorkoutSessionRow?> watchSession(String id) {
    return (select(workoutSessions)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  /// The most recent session still missing an end time, if any — used so
  /// re-opening the app can resume an in-progress workout.
  Stream<WorkoutSessionRow?> watchInProgressSession() {
    return (select(workoutSessions)
          ..where((tbl) => tbl.endTime.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<void> startSession(WorkoutSessionsCompanion entry) {
    return into(workoutSessions).insert(entry);
  }

  Future<bool> updateSession(WorkoutSessionsCompanion entry) {
    return update(workoutSessions).replace(entry);
  }

  Future<int> deleteSession(String id) {
    return (delete(workoutSessions)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Logged sets ---

  Stream<List<LoggedSetRow>> watchSetsForSession(String sessionId) {
    return (select(loggedSets)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.completedAt)]))
        .watch();
  }

  /// Most recent non-warmup sets for [exerciseId] across every session,
  /// most recent first — "previous performance" when starting to log
  /// that exercise again.
  Future<List<LoggedSetRow>> getRecentSetsForExercise(String exerciseId, {int limit = 10}) {
    return (select(loggedSets)
          ..where((tbl) => tbl.exerciseId.equals(exerciseId) & tbl.isWarmup.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)])
          ..limit(limit))
        .get();
  }

  /// Every set ever logged for [exerciseId] across every session, oldest
  /// first — the raw material for `StrengthProgressStats`'s per-exercise
  /// trend chart and PR list.
  Stream<List<LoggedSetRow>> watchAllSetsForExercise(String exerciseId) {
    return (select(loggedSets)
          ..where((tbl) => tbl.exerciseId.equals(exerciseId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.completedAt)]))
        .watch();
  }

  /// Heaviest weight ever logged for [exerciseId] (excluding warmups).
  Future<double?> getMaxWeightForExercise(String exerciseId) async {
    final query = selectOnly(loggedSets)
      ..addColumns([loggedSets.weight.max()])
      ..where(loggedSets.exerciseId.equals(exerciseId) & loggedSets.isWarmup.equals(false));
    final row = await query.getSingleOrNull();
    return row?.read(loggedSets.weight.max());
  }

  /// Inserts [entry] with its `isPr` flag computed fresh against the
  /// exercise's historical max weight (whatever the caller passed is
  /// overwritten), atomically. Returns whether it was a new PR.
  Future<bool> logSet(LoggedSetsCompanion entry) {
    return transaction(() async {
      bool isPr = false;
      if (!entry.isWarmup.value) {
        final double? maxWeight = await getMaxWeightForExercise(entry.exerciseId.value);
        isPr = maxWeight != null && entry.weight.value > maxWeight;
      }
      await into(loggedSets).insert(entry.copyWith(isPr: Value(isPr)));
      return isPr;
    });
  }

  Future<int> deleteLoggedSet(String id) {
    return (delete(loggedSets)..where((tbl) => tbl.id.equals(id))).go();
  }
}
