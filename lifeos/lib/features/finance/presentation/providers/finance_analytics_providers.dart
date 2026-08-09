import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/category_spending.dart';
import '../../domain/entities/monthly_totals.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/services/finance_analytics.dart';
import 'category_providers.dart';
import 'transaction_providers.dart';

const int analyticsMonthsBack = 6;

DateTime _firstOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

/// Income vs. expense per month for the last [analyticsMonthsBack]
/// months, oldest first.
final Provider<AsyncValue<List<MonthlyTotals>>> monthlyTotalsProvider =
    Provider<AsyncValue<List<MonthlyTotals>>>((ref) {
  final DateTime now = DateTime.now();
  final DateTime from = DateTime(now.year, now.month - (analyticsMonthsBack - 1), 1);
  final AsyncValue<List<TransactionEntry>> entriesAsync =
      ref.watch(transactionsInRangeProvider((from: from, to: now)));

  return entriesAsync.whenData(
    (entries) => FinanceAnalytics.monthlyTotals(
      entries: entries,
      monthsBack: analyticsMonthsBack,
      asOf: now,
    ),
  );
});

/// This calendar month's expense total broken down by category, largest
/// first — the Analytics screen's category breakdown chart.
final Provider<AsyncValue<List<CategorySpending>>> currentMonthSpendingProvider =
    Provider<AsyncValue<List<CategorySpending>>>((ref) {
  final DateTime now = DateTime.now();
  final DateTime from = _firstOfMonth(now);
  final AsyncValue<List<TransactionEntry>> entriesAsync =
      ref.watch(transactionsInRangeProvider((from: from, to: now)));
  final AsyncValue<List<Category>> categoriesAsync = ref.watch(allCategoriesProvider);

  final List<Category>? categories = categoriesAsync.valueOrNull;
  if (categories == null) {
    if (categoriesAsync.hasError) {
      return AsyncValue.error(
        categoriesAsync.error!,
        categoriesAsync.stackTrace ?? StackTrace.current,
      );
    }
    return const AsyncValue.loading();
  }

  return entriesAsync.whenData(
    (entries) => FinanceAnalytics.spendingByCategory(entries, categories),
  );
});
