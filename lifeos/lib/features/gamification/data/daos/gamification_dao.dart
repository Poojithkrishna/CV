import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/gamification_achievements_table.dart';

part 'gamification_dao.g.dart';

@DriftAccessor(tables: [GamificationAchievements])
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
}
