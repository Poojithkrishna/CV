import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/calendar_event.dart';
import 'calendar_providers.dart';

class EventFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<CalendarEvent>> save(CalendarEvent event, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<CalendarEvent> result = isEditing
        ? await ref.read(updateEventUseCaseProvider).call(event)
        : await ref.read(createEventUseCaseProvider).call(event);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<EventFormController, void> eventFormControllerProvider =
    AsyncNotifierProvider.autoDispose<EventFormController, void>(
  EventFormController.new,
);
