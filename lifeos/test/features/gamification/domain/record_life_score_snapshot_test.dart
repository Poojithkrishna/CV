import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/gamification/domain/entities/life_score_snapshot.dart';
import 'package:lifeos/features/gamification/domain/entities/rank.dart';
import 'package:lifeos/features/gamification/domain/entities/unlocked_achievement.dart';
import 'package:lifeos/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:lifeos/features/gamification/domain/usecases/record_life_score_snapshot.dart';

class _FakeGamificationRepository implements GamificationRepository {
  double? recordedLifeScore;
  int? recordedXp;
  Rank? recordedRank;

  @override
  Future<Result<void>> recordTodaysLifeScoreSnapshot({
    required double lifeScore,
    required int xp,
    required Rank rank,
  }) async {
    recordedLifeScore = lifeScore;
    recordedXp = xp;
    recordedRank = rank;
    return const Result.ok(null);
  }

  @override
  Stream<List<LifeScoreSnapshot>> watchLifeScoreSnapshots() => const Stream.empty();

  @override
  Future<Result<void>> unlockAchievement(String key) async => const Result.ok(null);

  @override
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements() => const Stream.empty();
}

void main() {
  group('RecordLifeScoreSnapshot', () {
    test('forwards Life Score, XP and rank to the repository', () async {
      final repo = _FakeGamificationRepository();
      final useCase = RecordLifeScoreSnapshot(repo);

      final result = await useCase(lifeScore: 62, xp: 3400, rank: Rank.coreFormation);

      expect(result.isOk, isTrue);
      expect(repo.recordedLifeScore, 62);
      expect(repo.recordedXp, 3400);
      expect(repo.recordedRank, Rank.coreFormation);
    });
  });
}
