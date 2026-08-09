import '../../../../core/utils/result.dart';
import '../repositories/measurement_repository.dart';

class DeleteMeasurement {
  DeleteMeasurement(this._repository);

  final MeasurementRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteEntry(id);
}
