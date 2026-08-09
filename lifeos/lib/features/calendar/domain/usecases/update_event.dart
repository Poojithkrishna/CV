import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';
import 'create_event.dart';

class UpdateEvent {
  UpdateEvent(this._repository);

  final CalendarRepository _repository;

  Future<Result<CalendarEvent>> call(CalendarEvent event) async {
    final Failure? error = CreateEvent.validate(event);
    if (error != null) return Result.err(error);
    return _repository.updateEvent(event);
  }
}
