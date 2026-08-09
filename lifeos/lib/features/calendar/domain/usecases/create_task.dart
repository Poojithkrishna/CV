import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/calendar_task.dart';
import '../repositories/calendar_repository.dart';

class CreateTask {
  CreateTask(this._repository);

  final CalendarRepository _repository;

  Future<Result<CalendarTask>> call(CalendarTask task) async {
    final Failure? error = validate(task);
    if (error != null) return Result.err(error);
    return _repository.createTask(task);
  }

  static Failure? validate(CalendarTask task) {
    if (task.title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    return null;
  }
}
