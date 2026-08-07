import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/workout_plan.dart';
import 'workout_plan_providers.dart';

class WorkoutPlanFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<WorkoutPlan>> save(WorkoutPlan plan, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<WorkoutPlan> result = isEditing
        ? await ref.read(updateWorkoutPlanUseCaseProvider).call(plan)
        : await ref.read(createWorkoutPlanUseCaseProvider).call(plan);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<WorkoutPlanFormController, void>
    workoutPlanFormControllerProvider =
    AsyncNotifierProvider.autoDispose<WorkoutPlanFormController, void>(
  WorkoutPlanFormController.new,
);
