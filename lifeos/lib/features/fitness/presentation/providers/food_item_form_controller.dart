import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/food_item.dart';
import 'nutrition_providers.dart';

class FoodItemFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<FoodItem>> save(FoodItem item, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<FoodItem> result = isEditing
        ? await ref.read(updateFoodItemUseCaseProvider).call(item)
        : await ref.read(createFoodItemUseCaseProvider).call(item);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<FoodItemFormController, void>
    foodItemFormControllerProvider = AsyncNotifierProvider.autoDispose<FoodItemFormController, void>(
  FoodItemFormController.new,
);
