import '../../../../core/database/app_database.dart';
import '../../domain/entities/unlocked_achievement.dart';

extension UnlockedAchievementRowMapper on UnlockedAchievementRow {
  UnlockedAchievement toDomain() {
    return UnlockedAchievement(key: key, unlockedAt: unlockedAt);
  }
}
