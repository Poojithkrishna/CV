import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/investment.dart';
import 'investment_providers.dart';

class InvestmentFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Investment>> save(Investment investment, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Investment> result = isEditing
        ? await ref.read(updateInvestmentUseCaseProvider).call(investment)
        : await ref.read(createInvestmentUseCaseProvider).call(investment);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<InvestmentFormController, void>
    investmentFormControllerProvider =
    AsyncNotifierProvider.autoDispose<InvestmentFormController, void>(
  InvestmentFormController.new,
);
