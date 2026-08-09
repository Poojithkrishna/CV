import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/calendar_dao.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_task.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task_done.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/update_task.dart';

final Provider<CalendarDao> calendarDaoProvider = Provider<CalendarDao>((ref) {
  return CalendarDao(ref.watch(appDatabaseProvider));
});

final Provider<CalendarRepository> calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(ref.watch(calendarDaoProvider));
});

final Provider<CreateTask> createTaskUseCaseProvider = Provider(
  (ref) => CreateTask(ref.watch(calendarRepositoryProvider)),
);
final Provider<UpdateTask> updateTaskUseCaseProvider = Provider(
  (ref) => UpdateTask(ref.watch(calendarRepositoryProvider)),
);
final Provider<DeleteTask> deleteTaskUseCaseProvider = Provider(
  (ref) => DeleteTask(ref.watch(calendarRepositoryProvider)),
);
final Provider<ToggleTaskDone> toggleTaskDoneUseCaseProvider = Provider(
  (ref) => ToggleTaskDone(ref.watch(calendarRepositoryProvider)),
);
final Provider<CreateEvent> createEventUseCaseProvider = Provider(
  (ref) => CreateEvent(ref.watch(calendarRepositoryProvider)),
);
final Provider<UpdateEvent> updateEventUseCaseProvider = Provider(
  (ref) => UpdateEvent(ref.watch(calendarRepositoryProvider)),
);
final Provider<DeleteEvent> deleteEventUseCaseProvider = Provider(
  (ref) => DeleteEvent(ref.watch(calendarRepositoryProvider)),
);

final StreamProvider<List<CalendarTask>> allTasksProvider = StreamProvider<List<CalendarTask>>((ref) {
  return ref.watch(calendarRepositoryProvider).watchAllTasks();
});

final StreamProviderFamily<CalendarTask?, String> taskByIdProvider =
    StreamProvider.family<CalendarTask?, String>((ref, id) {
  return ref.watch(calendarRepositoryProvider).watchTask(id);
});

final StreamProvider<List<CalendarEvent>> allEventsProvider =
    StreamProvider<List<CalendarEvent>>((ref) {
  return ref.watch(calendarRepositoryProvider).watchAllEvents();
});

final StreamProviderFamily<CalendarEvent?, String> eventByIdProvider =
    StreamProvider.family<CalendarEvent?, String>((ref, id) {
  return ref.watch(calendarRepositoryProvider).watchEvent(id);
});
