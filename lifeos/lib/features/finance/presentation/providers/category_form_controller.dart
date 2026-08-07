import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import 'category_providers.dart';

class CategoryFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Category>> save(Category category, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Category> result = isEditing
        ? await ref.read(updateCategoryUseCaseProvider).call(category)
        : await ref.read(createCategoryUseCaseProvider).call(category);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<CategoryFormController, void>
    categoryFormControllerProvider =
    AsyncNotifierProvider.autoDispose<CategoryFormController, void>(
  CategoryFormController.new,
);
