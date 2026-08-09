import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/measurement_entry.dart';
import '../repositories/measurement_repository.dart';

class LogMeasurement {
  LogMeasurement(this._repository);

  final MeasurementRepository _repository;

  Future<Result<MeasurementEntry>> call(MeasurementEntry entry) async {
    if (entry.valueCm <= 0) {
      return const Result.err(ValidationFailure('Value must be greater than zero.'));
    }
    return _repository.logMeasurement(entry);
  }
}
