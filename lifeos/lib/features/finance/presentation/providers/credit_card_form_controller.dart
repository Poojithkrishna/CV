import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/credit_card.dart';
import 'credit_card_providers.dart';

class CreditCardFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<CreditCard>> save(CreditCard card, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<CreditCard> result = isEditing
        ? await ref.read(updateCreditCardUseCaseProvider).call(card)
        : await ref.read(createCreditCardUseCaseProvider).call(card);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<CreditCardFormController, void>
    creditCardFormControllerProvider =
    AsyncNotifierProvider.autoDispose<CreditCardFormController, void>(
  CreditCardFormController.new,
);
