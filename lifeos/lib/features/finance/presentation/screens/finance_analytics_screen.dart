import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/category_spending.dart';
import '../../domain/entities/monthly_totals.dart';
import '../providers/finance_analytics_providers.dart';
import '../widgets/category_spending_chart.dart';
import '../widgets/income_expense_chart.dart';
import '../../../../app/origin/origin_glyphs.dart';

class FinanceAnalyticsScreen extends ConsumerWidget {
  const FinanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MonthlyTotals>> monthlyAsync = ref.watch(monthlyTotalsProvider);
    final AsyncValue<List<CategorySpending>> spendingAsync =
        ref.watch(currentMonthSpendingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            'Income vs. expense',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Last $analyticsMonthsBack months',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          monthlyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Something went wrong: $error'),
            data: (List<MonthlyTotals> months) {
              final double totalIncome = months.fold<double>(0, (sum, m) => sum + m.income);
              final double totalExpense = months.fold<double>(0, (sum, m) => sum + m.expense);
              final double savingsRate =
                  totalIncome <= 0 ? 0 : ((totalIncome - totalExpense) / totalIncome) * 100;

              if (totalIncome == 0 && totalExpense == 0) {
                return EmptyState(
                  glyph: OriginGlyphType.wealth,
                  icon: Icons.insights_outlined,
                  title: 'No transactions yet',
                  message: 'Log some income and expenses to see your trends here.',
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Income',
                          value: AppFormatters.currencyCompact(totalIncome),
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Expense',
                          value: AppFormatters.currencyCompact(totalExpense),
                          color: AppColors.expense,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Savings rate',
                          value: '${savingsRate.toStringAsFixed(0)}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  IncomeExpenseChart(months: months),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            'Spending by category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('This month', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          spendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Something went wrong: $error'),
            data: (List<CategorySpending> spending) {
              if (spending.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No expenses logged this month yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              return CategorySpendingChart(spending: spending);
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
