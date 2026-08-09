import 'package:flutter/foundation.dart' hide Category;

import 'category.dart';

/// Total spent against one category over some range — see
/// `FinanceAnalytics.spendingByCategory`.
@immutable
class CategorySpending {
  const CategorySpending({required this.category, required this.amount});

  final Category category;
  final double amount;
}
