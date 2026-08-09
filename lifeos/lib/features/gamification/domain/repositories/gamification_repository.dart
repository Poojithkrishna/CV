import '../../../../core/utils/result.dart';
import '../entities/unlocked_achievement.dart';

abstract interface class GamificationRepository {
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements();
  Future<Result<void>> unlockAchievement(String key);
}
