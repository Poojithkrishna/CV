import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/card_emi_mapper.dart';
import 'package:lifeos/features/finance/data/repositories/credit_card_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/card_emi.dart';
import 'package:lifeos/features/finance/domain/entities/credit_card.dart';

CreditCard _buildCard(String id, {double limit = 50000, double usage = 10000}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CreditCard(
    id: id,
    name: 'Card $id',
    creditLimit: limit,
    currentUsage: usage,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.creditCardsDao.insertCard(_buildCard('c1').toCompanion());
  });

  tearDown(() async {
    await database.close();
  });

  Future<double> usageOf(String id) async {
    final row = await database.creditCardsDao.getCard(id);
    return row!.currentUsage;
  }

  test('recording a charge increases usage', () async {
    await database.creditCardsDao.adjustUsage('c1', 2500);
    expect(await usageOf('c1'), 12500);
  });

  test('recording a payment decreases usage', () async {
    await database.creditCardsDao.adjustUsage('c1', -4000);
    expect(await usageOf('c1'), 6000);
  });

  test('marking an EMI installment paid increments monthsPaid and stops at tenure', () async {
    final DateTime now = DateTime(2026, 1, 1);
    final CardEmi emi = CardEmi(
      id: 'emi1',
      cardId: 'c1',
      description: 'Phone',
      totalAmount: 3000,
      monthlyAmount: 1000,
      tenureMonths: 3,
      startDate: now,
      createdAt: now,
      updatedAt: now,
    );
    await database.cardEmisDao.insertEmi(emi.toCompanion());

    await database.cardEmisDao.markInstallmentPaid('emi1');
    expect((await database.cardEmisDao.getEmi('emi1'))!.monthsPaid, 1);

    await database.cardEmisDao.markInstallmentPaid('emi1');
    await database.cardEmisDao.markInstallmentPaid('emi1');
    expect((await database.cardEmisDao.getEmi('emi1'))!.monthsPaid, 3);

    // A 4th call must not push monthsPaid past tenureMonths.
    await database.cardEmisDao.markInstallmentPaid('emi1');
    expect((await database.cardEmisDao.getEmi('emi1'))!.monthsPaid, 3);
  });
}
