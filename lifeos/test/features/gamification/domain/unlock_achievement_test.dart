import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/gamification/domain/entities/unlocked_achievement.dart';
import 'package:lifeos/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:lifeos/features/gamification/domain/usecases/unlock_achievement.dart';

class _FakeGamificationRepository implements GamificationRepository {
  String? unlockedKey;

  @override
  Future<Result<void>> unlockAchievement(String key) async {
    unlockedKey = key;
    return const Result.ok(null);
  }

  @override
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements() => const Stream.empty();
}

void main() {
  group('UnlockAchievement', () {
    test('forwards the key to the repository', () async {
      final repo = _FakeGamificationRepository();
      final useCase = UnlockAchievement(repo);

      final result = await useCase('rich_cultivator');

      expect(result.isOk, isTrue);
      expect(repo.unlockedKey, 'rich_cultivator');
    });
  });
}
