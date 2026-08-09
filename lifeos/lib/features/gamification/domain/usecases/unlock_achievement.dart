import '../../../../core/utils/result.dart';
import '../repositories/gamification_repository.dart';

class UnlockAchievement {
  UnlockAchievement(this._repository);

  final GamificationRepository _repository;

  Future<Result<void>> call(String key) => _repository.unlockAchievement(key);
}
