import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/account_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/account.dart';
import 'package:lifeos/features/finance/domain/entities/account_type.dart';

Account _buildAccount(String id, {bool isArchived = false, double balance = 500}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Account(
    id: id,
    name: 'Account $id',
    type: AccountType.bank,
    currentBalance: balance,
    openingBalance: balance,
    colorValue: 0xFF22C55E,
    isArchived: isArchived,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('insert then watch returns the active account', () async {
    await database.accountsDao.insertAccount(_buildAccount('a1').toCompanion());

    final List<AccountRow> rows =
        await database.accountsDao.watchActiveAccounts().first;

    expect(rows, hasLength(1));
    expect(rows.single.id, 'a1');
    expect(rows.single.currentBalance, 500);
  });

  test('archived accounts are excluded from the active stream', () async {
    await database.accountsDao.insertAccount(_buildAccount('a1').toCompanion());
    await database.accountsDao
        .insertAccount(_buildAccount('a2', isArchived: true).toCompanion());

    final List<AccountRow> active = await database.accountsDao.watchActiveAccounts().first;
    final List<AccountRow> archived =
        await database.accountsDao.watchArchivedAccounts().first;

    expect(active.map((r) => r.id), ['a1']);
    expect(archived.map((r) => r.id), ['a2']);
  });

  test('getBalanceTotals splits assets from liabilities', () async {
    await database.accountsDao
        .insertAccount(_buildAccount('bank', balance: 1000).toCompanion());
    await database.accountsDao.insertAccount(
      Account(
        id: 'card',
        name: 'Credit Card',
        type: AccountType.creditCard,
        currentBalance: -300,
        openingBalance: 0,
        colorValue: 0xFFEF4444,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ).toCompanion(),
    );

    final totals = await database.accountsDao.getBalanceTotals({'creditCard', 'loan'});

    expect(totals.assets, 1000);
    expect(totals.liabilities, 300);
  });

  test('deleteAccount removes the row', () async {
    await database.accountsDao.insertAccount(_buildAccount('a1').toCompanion());
    await database.accountsDao.deleteAccount('a1');

    final List<AccountRow> rows = await database.accountsDao.watchActiveAccounts().first;
    expect(rows, isEmpty);
  });
}
