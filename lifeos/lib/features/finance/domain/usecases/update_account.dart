import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/account.dart';
import '../repositories/account_repository.dart';

class UpdateAccount {
  UpdateAccount(this._repository);

  final AccountRepository _repository;

  Future<Result<Account>> call(Account account) async {
    if (account.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('Account name is required.'));
    }
    if (account.interestRate != null &&
        (account.interestRate! < 0 || account.interestRate! > 100)) {
      return const Result.err(
        ValidationFailure('Interest rate must be between 0 and 100.'),
      );
    }
    return _repository.updateAccount(account.copyWith(updatedAt: DateTime.now()));
  }
}
