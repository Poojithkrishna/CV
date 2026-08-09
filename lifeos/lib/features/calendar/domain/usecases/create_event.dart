import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';

class CreateEvent {
  CreateEvent(this._repository);

  final CalendarRepository _repository;

  Future<Result<CalendarEvent>> call(CalendarEvent event) async {
    final Failure? error = validate(event);
    if (error != null) return Result.err(error);
    return _repository.createEvent(event);
  }

  static Failure? validate(CalendarEvent event) {
    if (event.title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    if (event.endTime != null && event.endTime!.isBefore(event.startTime)) {
      return const ValidationFailure('End time must be after the start time.');
    }
    return null;
  }
}
