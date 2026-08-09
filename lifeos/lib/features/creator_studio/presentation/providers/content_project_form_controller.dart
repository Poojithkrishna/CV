import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/content_project.dart';
import 'content_studio_providers.dart';

class ContentProjectFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<ContentProject>> save(ContentProject project, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<ContentProject> result = isEditing
        ? await ref.read(updateContentProjectUseCaseProvider).call(project)
        : await ref.read(createContentProjectUseCaseProvider).call(project);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<ContentProjectFormController, void>
    contentProjectFormControllerProvider =
    AsyncNotifierProvider.autoDispose<ContentProjectFormController, void>(
  ContentProjectFormController.new,
);
