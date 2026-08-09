import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/investment_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/investment.dart';
import 'package:lifeos/features/finance/domain/entities/investment_type.dart';

Investment _buildInvestment(String id, {bool isArchived = false, double currentValue = 1200}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Investment(
    id: id,
    name: 'Investment $id',
    type: InvestmentType.stocks,
    investedAmount: 1000,
    currentValue: currentValue,
    colorValue: 0xFF7C4DFF,
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

  test('insertInvestment persists a row retrievable by watchInvestment', () async {
    await database.investmentsDao.insertInvestment(_buildInvestment('i1').toCompanion());

    final row = await database.investmentsDao.watchInvestment('i1').first;
    expect(row?.currentValue, 1200);
  });

  test('watchActiveInvestments excludes archived investments', () async {
    await database.investmentsDao.insertInvestment(_buildInvestment('i1').toCompanion());
    await database.investmentsDao.insertInvestment(
      _buildInvestment('i2', isArchived: true).toCompanion(),
    );

    final active = await database.investmentsDao.watchActiveInvestments().first;
    expect(active.map((r) => r.id), ['i1']);
  });

  test('updateInvestment replaces the stored value', () async {
    await database.investmentsDao.insertInvestment(_buildInvestment('i1').toCompanion());
    await database.investmentsDao.updateInvestment(
      _buildInvestment('i1', currentValue: 1500).toCompanion(),
    );

    final row = await database.investmentsDao.watchInvestment('i1').first;
    expect(row?.currentValue, 1500);
  });

  test('deleteInvestment removes the row', () async {
    await database.investmentsDao.insertInvestment(_buildInvestment('i1').toCompanion());
    await database.investmentsDao.deleteInvestment('i1');

    final row = await database.investmentsDao.watchInvestment('i1').first;
    expect(row, isNull);
  });
}
