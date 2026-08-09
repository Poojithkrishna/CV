import 'package:flutter/foundation.dart';

/// Income vs. expense totals for one calendar month — see
/// `FinanceAnalytics.monthlyTotals`.
@immutable
class MonthlyTotals {
  const MonthlyTotals({required this.month, this.income = 0, this.expense = 0});

  /// Normalized to the first of the month.
  final DateTime month;
  final double income;
  final double expense;

  double get net => income - expense;
}
