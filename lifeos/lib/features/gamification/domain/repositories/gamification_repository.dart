import '../../../../core/utils/result.dart';
import '../entities/life_score_snapshot.dart';
import '../entities/rank.dart';
import '../entities/unlocked_achievement.dart';

abstract interface class GamificationRepository {
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements();
  Future<Result<void>> unlockAchievement(String key);

  Stream<List<LifeScoreSnapshot>> watchLifeScoreSnapshots();

  /// Records today's Life Score/XP/rank, overwriting today's row if one
  /// was already recorded earlier the same day.
  Future<Result<void>> recordTodaysLifeScoreSnapshot({
    required double lifeScore,
    required int xp,
    required Rank rank,
  });
}
