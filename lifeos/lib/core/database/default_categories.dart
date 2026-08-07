import 'package:drift/drift.dart';

import 'app_database.dart';

/// Starter categories inserted the first time the database is created, so
/// the Transactions form isn't empty on day one. Ids are fixed (not
/// random) so they're stable across reinstalls and easy to reference in
/// tests; users can rename, recolor, archive or delete any of them freely
/// like any other category.
List<CategoriesCompanion> buildDefaultCategorySeed(DateTime now) {
  CategoriesCompanion category({
    required String id,
    required String name,
    required String type,
    required String iconKey,
    required int colorValue,
    required int sortOrder,
  }) {
    return CategoriesCompanion.insert(
      id: id,
      name: name,
      type: type,
      iconKey: Value(iconKey),
      colorValue: colorValue,
      sortOrder: Value(sortOrder),
      createdAt: now,
      updatedAt: now,
    );
  }

  return [
    category(
      id: 'seed-income-salary',
      name: 'Salary',
      type: 'income',
      iconKey: 'salary',
      colorValue: 0xFF22C55E,
      sortOrder: 0,
    ),
    category(
      id: 'seed-income-freelance',
      name: 'Freelance',
      type: 'income',
      iconKey: 'freelance',
      colorValue: 0xFF06B6D4,
      sortOrder: 1,
    ),
    category(
      id: 'seed-income-gifts',
      name: 'Gifts',
      type: 'income',
      iconKey: 'gift',
      colorValue: 0xFFEC4899,
      sortOrder: 2,
    ),
    category(
      id: 'seed-income-other',
      name: 'Other income',
      type: 'income',
      iconKey: 'other',
      colorValue: 0xFF64748B,
      sortOrder: 3,
    ),
    category(
      id: 'seed-expense-food',
      name: 'Food',
      type: 'expense',
      iconKey: 'food',
      colorValue: 0xFFF59E0B,
      sortOrder: 0,
    ),
    category(
      id: 'seed-expense-transport',
      name: 'Transport',
      type: 'expense',
      iconKey: 'transport',
      colorValue: 0xFF3B82F6,
      sortOrder: 1,
    ),
    category(
      id: 'seed-expense-shopping',
      name: 'Shopping',
      type: 'expense',
      iconKey: 'shopping',
      colorValue: 0xFF8B5CF6,
      sortOrder: 2,
    ),
    category(
      id: 'seed-expense-bills',
      name: 'Bills & Utilities',
      type: 'expense',
      iconKey: 'bills',
      colorValue: 0xFFEF4444,
      sortOrder: 3,
    ),
    category(
      id: 'seed-expense-entertainment',
      name: 'Entertainment',
      type: 'expense',
      iconKey: 'entertainment',
      colorValue: 0xFFDC2626,
      sortOrder: 4,
    ),
    category(
      id: 'seed-expense-health',
      name: 'Health',
      type: 'expense',
      iconKey: 'health',
      colorValue: 0xFF14B8A6,
      sortOrder: 5,
    ),
    category(
      id: 'seed-expense-education',
      name: 'Education',
      type: 'expense',
      iconKey: 'education',
      colorValue: 0xFF7C4DFF,
      sortOrder: 6,
    ),
    category(
      id: 'seed-expense-other',
      name: 'Other expense',
      type: 'expense',
      iconKey: 'other',
      colorValue: 0xFF64748B,
      sortOrder: 7,
    ),
  ];
}
