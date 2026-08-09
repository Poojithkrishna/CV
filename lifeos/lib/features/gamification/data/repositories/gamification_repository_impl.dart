import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/unlocked_achievement.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../daos/gamification_dao.dart';
import 'unlocked_achievement_mapper.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  GamificationRepositoryImpl(this._dao);

  final GamificationDao _dao;

  @override
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements() {
    return _dao
        .watchUnlockedAchievements()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<void>> unlockAchievement(String key) async {
    try {
      await _dao.unlockAchievement(key);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not unlock achievement: $e'));
    }
  }
}
