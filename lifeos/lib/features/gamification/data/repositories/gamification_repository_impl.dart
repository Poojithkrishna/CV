import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/life_score_snapshot.dart';
import '../../domain/entities/rank.dart';
import '../../domain/entities/unlocked_achievement.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../daos/gamification_dao.dart';
import 'life_score_snapshot_mapper.dart';
import 'unlocked_achievement_mapper.dart';

const Uuid _uuid = Uuid();

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

  @override
  Stream<List<LifeScoreSnapshot>> watchLifeScoreSnapshots() {
    return _dao
        .watchLifeScoreSnapshots()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<void>> recordTodaysLifeScoreSnapshot({
    required double lifeScore,
    required int xp,
    required Rank rank,
  }) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      await _dao.upsertTodaysSnapshot(
        id: _uuid.v4(),
        date: today,
        lifeScore: lifeScore,
        xp: xp,
        rankIndex: rank.index,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not record Life Score snapshot: $e'));
    }
  }
}
