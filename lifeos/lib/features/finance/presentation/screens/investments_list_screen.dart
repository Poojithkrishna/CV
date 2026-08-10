import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/investment.dart';
import '../providers/investment_providers.dart';
import '../widgets/investment_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class InvestmentsListScreen extends ConsumerWidget {
  const InvestmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Investment>> investmentsAsync = ref.watch(activeInvestmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/investments/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Investment'),
      ),
      body: investmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Investment> investments) {
          if (investments.isEmpty) {
            return EmptyState(
              icon: Icons.trending_up_rounded,
              title: 'No investments yet',
              message: 'Track stocks, mutual funds, crypto and more here.',
              actionLabel: 'Add your first investment',
              onAction: () => context.push('/finance/investments/new'),
            );
          }

          final double totalInvested =
              investments.fold<double>(0, (sum, i) => sum + i.investedAmount);
          final double totalCurrent =
              investments.fold<double>(0, (sum, i) => sum + i.currentValue);
          final double totalGain = totalCurrent - totalInvested;
          final bool isGain = totalGain >= 0;
          final Color gainColor = isGain ? AppColors.income : AppColors.expense;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current value', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(totalCurrent),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isGain ? '+' : ''}${AppFormatters.currency(totalGain)} overall'
                      ' (invested ${AppFormatters.currency(totalInvested)})',
                      style: TextStyle(color: gainColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final Investment investment in investments)
                InvestmentTile(
                  investment: investment,
                  onTap: () => context.push('/finance/investments/${investment.id}/edit'),
                ),
            ],
          );
        },
      ),
    );
  }
}
