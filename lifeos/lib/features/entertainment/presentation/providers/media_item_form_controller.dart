import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/media_item.dart';
import 'media_library_providers.dart';

class MediaItemFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<MediaItem>> save(MediaItem item, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<MediaItem> result = isEditing
        ? await ref.read(updateMediaItemUseCaseProvider).call(item)
        : await ref.read(createMediaItemUseCaseProvider).call(item);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<MediaItemFormController, void> mediaItemFormControllerProvider =
    AsyncNotifierProvider.autoDispose<MediaItemFormController, void>(
  MediaItemFormController.new,
);
