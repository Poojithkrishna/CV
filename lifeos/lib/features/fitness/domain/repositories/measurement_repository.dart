import '../../../../core/utils/result.dart';
import '../entities/measurement_entry.dart';
import '../entities/measurement_type.dart';

abstract interface class MeasurementRepository {
  Stream<List<MeasurementEntry>> watchEntriesForType(MeasurementType type);
  Stream<List<MeasurementEntry>> watchAllEntries();

  Future<Result<MeasurementEntry>> logMeasurement(MeasurementEntry entry);
  Future<Result<void>> deleteEntry(String id);
}
