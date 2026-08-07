import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/loan.dart';
import 'loan_providers.dart';

class LoanFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Loan>> save(Loan loan, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Loan> result = isEditing
        ? await ref.read(updateLoanUseCaseProvider).call(loan)
        : await ref.read(createLoanUseCaseProvider).call(loan);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<LoanFormController, void> loanFormControllerProvider =
    AsyncNotifierProvider.autoDispose<LoanFormController, void>(
  LoanFormController.new,
);
