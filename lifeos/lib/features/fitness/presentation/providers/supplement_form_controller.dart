import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/supplement.dart';
import 'supplement_providers.dart';

class SupplementFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Supplement>> save(Supplement supplement, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Supplement> result = isEditing
        ? await ref.read(updateSupplementUseCaseProvider).call(supplement)
        : await ref.read(createSupplementUseCaseProvider).call(supplement);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<SupplementFormController, void>
    supplementFormControllerProvider =
    AsyncNotifierProvider.autoDispose<SupplementFormController, void>(
  SupplementFormController.new,
);
