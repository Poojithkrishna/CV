import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

/// Validates and persists a brand-new account. Kept separate from the
/// repository so form-level and any future bulk-import callers share the
/// same business rules instead of re-validating ad hoc.
class CreateAccount {
  CreateAccount(this._repository);

  final AccountRepository _repository;

  Future<Result<Account>> call(Account account) async {
    final Failure? validationError = _validate(account);
    if (validationError != null) {
      return Result.err(validationError);
    }
    return _repository.createAccount(account);
  }

  Failure? _validate(Account account) {
    if (account.name.trim().isEmpty) {
      return const ValidationFailure('Account name is required.');
    }
    if (account.interestRate != null &&
        (account.interestRate! < 0 || account.interestRate! > 100)) {
      return const ValidationFailure('Interest rate must be between 0 and 100.');
    }
    return null;
  }
}
