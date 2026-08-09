import '../../../../core/utils/result.dart';
import '../repositories/calendar_repository.dart';

class ToggleTaskDone {
  ToggleTaskDone(this._repository);

  final CalendarRepository _repository;

  Future<Result<void>> call(String id) => _repository.toggleTaskDone(id);
}
