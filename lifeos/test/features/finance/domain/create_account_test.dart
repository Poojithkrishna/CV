import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/error/failures.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/account.dart';
import 'package:lifeos/features/finance/domain/entities/account_type.dart';
import 'package:lifeos/features/finance/domain/repositories/account_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_account.dart';

class _FakeAccountRepository implements AccountRepository {
  Account? saved;

  @override
  Future<Result<Account>> createAccount(Account account) async {
    saved = account;
    return Result.ok(account);
  }

  @override
  Future<Result<void>> archiveAccount(String id, {required bool archived}) async =>
      const Result.ok(null);

  @override
  Future<Result<void>> deleteAccount(String id) async => const Result.ok(null);

  @override
  Future<NetWorthSummary> getNetWorthSummary() async =>
      (assets: 0.0, liabilities: 0.0, netWorth: 0.0);

  @override
  Future<Result<Account>> updateAccount(Account account) async => Result.ok(account);

  @override
  Stream<Account?> watchAccount(String id) => const Stream.empty();

  @override
  Stream<List<Account>> watchActiveAccounts() => const Stream.empty();

  @override
  Stream<List<Account>> watchArchivedAccounts() => const Stream.empty();
}

Account _buildAccount({
  String name = 'HDFC Savings',
  double? interestRate,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Account(
    id: 'acc-1',
    name: name,
    type: AccountType.bank,
    currentBalance: 1000,
    openingBalance: 1000,
    colorValue: 0xFF22C55E,
    interestRate: interestRate,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateAccount', () {
    test('persists a valid account', () async {
      final _FakeAccountRepository repository = _FakeAccountRepository();
      final CreateAccount useCase = CreateAccount(repository);

      final Result<Account> result = await useCase(_buildAccount());

      expect(result.isOk, isTrue);
      expect(repository.saved?.name, 'HDFC Savings');
    });

    test('rejects a blank name without touching the repository', () async {
      final _FakeAccountRepository repository = _FakeAccountRepository();
      final CreateAccount useCase = CreateAccount(repository);

      final Result<Account> result = await useCase(_buildAccount(name: '   '));

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(repository.saved, isNull);
    });

    test('rejects an interest rate outside 0-100', () async {
      final _FakeAccountRepository repository = _FakeAccountRepository();
      final CreateAccount useCase = CreateAccount(repository);

      final Result<Account> result =
          await useCase(_buildAccount(interestRate: 150));

      expect(result.isErr, isTrue);
      expect(repository.saved, isNull);
    });
  });
}
