import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/exercise.dart';
import 'exercise_providers.dart';

class ExerciseFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Exercise>> save(Exercise exercise, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Exercise> result = isEditing
        ? await ref.read(updateExerciseUseCaseProvider).call(exercise)
        : await ref.read(createExerciseUseCaseProvider).call(exercise);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<ExerciseFormController, void> exerciseFormControllerProvider =
    AsyncNotifierProvider.autoDispose<ExerciseFormController, void>(
  ExerciseFormController.new,
);
