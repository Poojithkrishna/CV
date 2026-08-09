import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/cardio_session.dart';
import 'cardio_providers.dart';

class CardioFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<CardioSession>> save(CardioSession session, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<CardioSession> result = isEditing
        ? await ref.read(updateCardioSessionUseCaseProvider).call(session)
        : await ref.read(logCardioSessionUseCaseProvider).call(session);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<CardioFormController, void> cardioFormControllerProvider =
    AsyncNotifierProvider.autoDispose<CardioFormController, void>(
  CardioFormController.new,
);
