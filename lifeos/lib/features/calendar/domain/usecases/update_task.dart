import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/calendar_task.dart';
import '../repositories/calendar_repository.dart';
import 'create_task.dart';

class UpdateTask {
  UpdateTask(this._repository);

  final CalendarRepository _repository;

  Future<Result<CalendarTask>> call(CalendarTask task) async {
    final Failure? error = CreateTask.validate(task);
    if (error != null) return Result.err(error);
    return _repository.updateTask(task);
  }
}
