import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';
import 'habit_providers.dart';

class HabitFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Habit>> save(Habit habit, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Habit> result = isEditing
        ? await ref.read(updateHabitUseCaseProvider).call(habit)
        : await ref.read(createHabitUseCaseProvider).call(habit);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<HabitFormController, void> habitFormControllerProvider =
    AsyncNotifierProvider.autoDispose<HabitFormController, void>(
  HabitFormController.new,
);
