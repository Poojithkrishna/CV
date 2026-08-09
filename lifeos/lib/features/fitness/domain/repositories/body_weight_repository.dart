import '../../../../core/utils/result.dart';
import '../entities/body_weight_entry.dart';

abstract interface class BodyWeightRepository {
  Stream<List<BodyWeightEntry>> watchAllEntries();
  Stream<BodyWeightEntry?> watchEntryForDate(DateTime date);

  Future<Result<BodyWeightEntry>> logWeight(BodyWeightEntry entry);
  Future<Result<void>> deleteEntry(String id);
}
