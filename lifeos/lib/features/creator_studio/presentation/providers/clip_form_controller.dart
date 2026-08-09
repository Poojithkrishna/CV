import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/clip.dart';
import 'content_studio_providers.dart';

class ClipFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Clip>> save(Clip clip, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Clip> result = isEditing
        ? await ref.read(updateClipUseCaseProvider).call(clip)
        : await ref.read(createClipUseCaseProvider).call(clip);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<ClipFormController, void> clipFormControllerProvider =
    AsyncNotifierProvider.autoDispose<ClipFormController, void>(
  ClipFormController.new,
);
