import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/calendar_task.dart';
import 'calendar_providers.dart';

class TaskFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<CalendarTask>> save(CalendarTask task, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<CalendarTask> result = isEditing
        ? await ref.read(updateTaskUseCaseProvider).call(task)
        : await ref.read(createTaskUseCaseProvider).call(task);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<TaskFormController, void> taskFormControllerProvider =
    AsyncNotifierProvider.autoDispose<TaskFormController, void>(
  TaskFormController.new,
);
