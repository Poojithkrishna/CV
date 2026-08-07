import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/goal.dart';
import 'goal_providers.dart';

class GoalFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Goal>> save(Goal goal, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Goal> result = isEditing
        ? await ref.read(updateGoalUseCaseProvider).call(goal)
        : await ref.read(createGoalUseCaseProvider).call(goal);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<GoalFormController, void> goalFormControllerProvider =
    AsyncNotifierProvider.autoDispose<GoalFormController, void>(
  GoalFormController.new,
);
