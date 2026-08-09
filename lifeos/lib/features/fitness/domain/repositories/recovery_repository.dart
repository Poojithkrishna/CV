import '../../../../core/utils/result.dart';
import '../entities/recovery_entry.dart';

abstract interface class RecoveryRepository {
  Stream<List<RecoveryEntry>> watchAllEntries();
  Stream<RecoveryEntry?> watchEntryForDate(DateTime date);

  Future<Result<RecoveryEntry>> logRecovery(RecoveryEntry entry);
  Future<Result<void>> deleteEntry(String id);
}
