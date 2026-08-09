import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/finance/domain/entities/category.dart';
import 'package:lifeos/features/finance/domain/entities/category_type.dart';
import 'package:lifeos/features/finance/domain/entities/monthly_totals.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_entry.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_type.dart';
import 'package:lifeos/features/finance/domain/services/finance_analytics.dart';

Category _category(String id, {String name = 'Food'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Category(
    id: id,
    name: name,
    type: CategoryType.expense,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

TransactionEntry _entry({
  String id = 't1',
  TransactionType type = TransactionType.expense,
  required double amount,
  required DateTime date,
  String? categoryId,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return TransactionEntry(
    id: id,
    accountId: 'a1',
    type: type,
    amount: amount,
    date: date,
    categoryId: categoryId,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('FinanceAnalytics.totalIncome / totalExpense', () {
    test('sums only entries of the matching type', () {
      final entries = [
        _entry(type: TransactionType.income, amount: 1000, date: DateTime(2026, 1, 1)),
        _entry(type: TransactionType.expense, amount: 300, date: DateTime(2026, 1, 2)),
        _entry(type: TransactionType.transfer, amount: 500, date: DateTime(2026, 1, 3)),
      ];

      expect(FinanceAnalytics.totalIncome(entries), 1000);
      expect(FinanceAnalytics.totalExpense(entries), 300);
    });

    test('returns zero for an empty list', () {
      expect(FinanceAnalytics.totalIncome(const []), 0);
      expect(FinanceAnalytics.totalExpense(const []), 0);
    });
  });

  group('FinanceAnalytics.spendingByCategory', () {
    test('sums expenses per category, largest first', () {
      final food = _category('c1', name: 'Food');
      final transport = _category('c2', name: 'Transport');
      final entries = [
        _entry(id: 't1', amount: 100, date: DateTime(2026, 1, 1), categoryId: 'c1'),
        _entry(id: 't2', amount: 50, date: DateTime(2026, 1, 2), categoryId: 'c1'),
        _entry(id: 't3', amount: 200, date: DateTime(2026, 1, 3), categoryId: 'c2'),
      ];

      final result = FinanceAnalytics.spendingByCategory(entries, [food, transport]);

      expect(result.length, 2);
      expect(result.first.category.name, 'Transport');
      expect(result.first.amount, 200);
      expect(result.last.category.name, 'Food');
      expect(result.last.amount, 150);
    });

    test('excludes income and transfer entries', () {
      final food = _category('c1');
      final entries = [
        _entry(type: TransactionType.income, amount: 5000, date: DateTime(2026, 1, 1), categoryId: 'c1'),
        _entry(type: TransactionType.expense, amount: 80, date: DateTime(2026, 1, 2), categoryId: 'c1'),
      ];

      final result = FinanceAnalytics.spendingByCategory(entries, [food]);

      expect(result.single.amount, 80);
    });

    test('excludes entries whose category no longer exists', () {
      final entries = [
        _entry(amount: 100, date: DateTime(2026, 1, 1), categoryId: 'missing'),
      ];

      final result = FinanceAnalytics.spendingByCategory(entries, const []);

      expect(result, isEmpty);
    });
  });

  group('FinanceAnalytics.monthlyTotals', () {
    test('buckets entries into the right calendar month', () {
      final entries = [
        _entry(type: TransactionType.income, amount: 1000, date: DateTime(2025, 12, 15)),
        _entry(type: TransactionType.expense, amount: 300, date: DateTime(2025, 12, 20)),
        _entry(type: TransactionType.income, amount: 1200, date: DateTime(2026, 1, 5)),
        _entry(type: TransactionType.expense, amount: 400, date: DateTime(2026, 1, 10)),
      ];

      final List<MonthlyTotals> months = FinanceAnalytics.monthlyTotals(
        entries: entries,
        monthsBack: 2,
        asOf: DateTime(2026, 1, 15),
      );

      expect(months.length, 2);
      expect(months[0].month, DateTime(2025, 12, 1));
      expect(months[0].income, 1000);
      expect(months[0].expense, 300);
      expect(months[1].month, DateTime(2026, 1, 1));
      expect(months[1].income, 1200);
      expect(months[1].expense, 400);
    });

    test('excludes transfers and out-of-range months', () {
      final entries = [
        _entry(type: TransactionType.transfer, amount: 500, date: DateTime(2026, 1, 5)),
        _entry(type: TransactionType.income, amount: 100, date: DateTime(2025, 6, 1)),
      ];

      final months = FinanceAnalytics.monthlyTotals(
        entries: entries,
        monthsBack: 3,
        asOf: DateTime(2026, 1, 15),
      );

      expect(months.every((m) => m.income == 0 && m.expense == 0), isTrue);
    });

    test('returns a bucket even for months with no activity', () {
      final months = FinanceAnalytics.monthlyTotals(
        entries: const [],
        monthsBack: 3,
        asOf: DateTime(2026, 3, 1),
      );

      expect(months.map((m) => m.month), [
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
      ]);
    });
  });
}
