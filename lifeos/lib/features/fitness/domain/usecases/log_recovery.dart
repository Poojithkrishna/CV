import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/recovery_entry.dart';
import '../repositories/recovery_repository.dart';

class LogRecovery {
  LogRecovery(this._repository);

  final RecoveryRepository _repository;

  Future<Result<RecoveryEntry>> call(RecoveryEntry entry) async {
    final Failure? error = validate(entry);
    if (error != null) return Result.err(error);
    return _repository.logRecovery(entry);
  }

  static Failure? validate(RecoveryEntry entry) {
    if (entry.sleepHours != null && entry.sleepHours! < 0) {
      return const ValidationFailure('Sleep hours cannot be negative.');
    }
    if (entry.sorenessLevel != null && (entry.sorenessLevel! < 1 || entry.sorenessLevel! > 5)) {
      return const ValidationFailure('Soreness must be between 1 and 5.');
    }
    if (entry.stressLevel != null && (entry.stressLevel! < 1 || entry.stressLevel! > 5)) {
      return const ValidationFailure('Stress must be between 1 and 5.');
    }
    return null;
  }
}
