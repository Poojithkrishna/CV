import '../entities/category.dart';
import '../entities/category_spending.dart';
import '../entities/monthly_totals.dart';
import '../entities/transaction_entry.dart';
import '../entities/transaction_type.dart';

/// Pure, DB-free aggregation over already-loaded transactions — the
/// Analytics screen's income/expense trend and category breakdown.
class FinanceAnalytics {
  FinanceAnalytics._();

  static double totalIncome(List<TransactionEntry> entries) {
    return entries
        .where((e) => e.type == TransactionType.income)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  static double totalExpense(List<TransactionEntry> entries) {
    return entries
        .where((e) => e.type == TransactionType.expense)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  /// Expense totals grouped by category, largest first. Entries with no
  /// category (shouldn't normally happen for an expense) or whose
  /// category no longer exists are silently excluded.
  static List<CategorySpending> spendingByCategory(
    List<TransactionEntry> entries,
    List<Category> categories,
  ) {
    final Map<String, Category> categoryById = {for (final c in categories) c.id: c};
    final Map<String, double> totals = {};

    for (final TransactionEntry entry in entries) {
      if (entry.type != TransactionType.expense) continue;
      final String? categoryId = entry.categoryId;
      if (categoryId == null) continue;
      totals[categoryId] = (totals[categoryId] ?? 0) + entry.amount;
    }

    final List<CategorySpending> result = [
      for (final MapEntry<String, double> total in totals.entries)
        if (categoryById[total.key] case final Category category)
          CategorySpending(category: category, amount: total.value),
    ];
    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  /// One bucket per calendar month, oldest first, covering [monthsBack]
  /// months up to and including [asOf]'s month. Transfers are excluded —
  /// moving money between your own accounts is neither income nor spend.
  static List<MonthlyTotals> monthlyTotals({
    required List<TransactionEntry> entries,
    required int monthsBack,
    required DateTime asOf,
  }) {
    final List<DateTime> months = [
      for (int i = monthsBack - 1; i >= 0; i--) DateTime(asOf.year, asOf.month - i, 1),
    ];
    final Map<DateTime, MonthlyTotals> byMonth = {
      for (final DateTime m in months) m: MonthlyTotals(month: m),
    };

    for (final TransactionEntry entry in entries) {
      if (entry.isTransfer) continue;
      final DateTime bucket = DateTime(entry.date.year, entry.date.month, 1);
      final MonthlyTotals? existing = byMonth[bucket];
      if (existing == null) continue;
      byMonth[bucket] = MonthlyTotals(
        month: bucket,
        income: existing.income + (entry.type == TransactionType.income ? entry.amount : 0),
        expense: existing.expense + (entry.type == TransactionType.expense ? entry.amount : 0),
      );
    }

    return [for (final DateTime m in months) byMonth[m]!];
  }
}
