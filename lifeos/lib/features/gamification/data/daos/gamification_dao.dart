import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/gamification_achievements_table.dart';
import '../tables/life_score_snapshots_table.dart';

part 'gamification_dao.g.dart';

@DriftAccessor(tables: [GamificationAchievements, LifeScoreSnapshots])
class GamificationDao extends DatabaseAccessor<AppDatabase> with _$GamificationDaoMixin {
  GamificationDao(super.db);

  Stream<List<UnlockedAchievementRow>> watchUnlockedAchievements() {
    return select(gamificationAchievements).watch();
  }

  /// Inserts an unlock record for [key] if one doesn't already exist.
  /// Achievements are never re-unlocked or overwritten once earned.
  Future<void> unlockAchievement(String key) async {
    final UnlockedAchievementRow? existing = await (select(gamificationAchievements)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    if (existing != null) return;
    await into(gamificationAchievements).insert(
      GamificationAchievementsCompanion.insert(key: key, unlockedAt: DateTime.now()),
    );
  }

  Stream<List<LifeScoreSnapshotRow>> watchLifeScoreSnapshots() {
    return (select(lifeScoreSnapshots)..orderBy([(tbl) => OrderingTerm.asc(tbl.date)])).watch();
  }

  /// Inserts today's snapshot, or — if today already has one — updates
  /// that existing row instead, so opening the app more than once in a
  /// day overwrites rather than duplicating (mirrors
  /// `BodyWeightDao.upsertForDate`).
  Future<void> upsertTodaysSnapshot({
    required String id,
    required DateTime date,
    required double lifeScore,
    required int xp,
    required int rankIndex,
  }) {
    return transaction(() async {
      final LifeScoreSnapshotRow? existing =
          await (select(lifeScoreSnapshots)..where((tbl) => tbl.date.equals(date))).getSingleOrNull();
      final DateTime now = DateTime.now();
      if (existing == null) {
        await into(lifeScoreSnapshots).insert(
          LifeScoreSnapshotsCompanion.insert(
            id: id,
            date: date,
            lifeScore: lifeScore,
            xp: xp,
            rankIndex: rankIndex,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await (update(lifeScoreSnapshots)..where((tbl) => tbl.id.equals(existing.id))).write(
          LifeScoreSnapshotsCompanion(
            lifeScore: Value(lifeScore),
            xp: Value(xp),
            rankIndex: Value(rankIndex),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
