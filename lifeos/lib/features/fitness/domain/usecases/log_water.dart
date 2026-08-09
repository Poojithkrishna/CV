import '../../../../core/utils/result.dart';
import '../repositories/water_repository.dart';

class LogWater {
  LogWater(this._repository);

  final WaterRepository _repository;

  Future<Result<void>> call(DateTime date, int deltaMl) => _repository.logWater(date, deltaMl);
}
