import '../../../../core/utils/result.dart';
import '../entities/rank.dart';
import '../repositories/gamification_repository.dart';

class RecordLifeScoreSnapshot {
  RecordLifeScoreSnapshot(this._repository);

  final GamificationRepository _repository;

  Future<Result<void>> call({
    required double lifeScore,
    required int xp,
    required Rank rank,
  }) {
    return _repository.recordTodaysLifeScoreSnapshot(lifeScore: lifeScore, xp: xp, rank: rank);
  }
}
