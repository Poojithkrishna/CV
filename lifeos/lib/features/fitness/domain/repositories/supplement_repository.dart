import '../../../../core/utils/result.dart';
import '../entities/supplement.dart';
import '../entities/supplement_log_entry.dart';

abstract interface class SupplementRepository {
  Stream<List<Supplement>> watchActiveSupplements();
  Stream<Supplement?> watchSupplement(String id);

  Future<Result<Supplement>> createSupplement(Supplement supplement);
  Future<Result<Supplement>> updateSupplement(Supplement supplement);
  Future<Result<void>> deleteSupplement(String id);

  Stream<SupplementLogEntry?> watchLogEntryForDate(String supplementId, DateTime date);
  Future<Result<void>> toggleTaken(String supplementId, DateTime date);
}
