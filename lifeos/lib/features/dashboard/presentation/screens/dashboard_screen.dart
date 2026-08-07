import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../finance/presentation/providers/finance_providers.dart';
import '../widgets/module_summary_card.dart';

/// The LifeOS home screen: a single glance at every module. Finance's net
/// worth tile is wired to real data; every other tile is a placeholder
/// until that module's own feature pass lands, but they're already
/// tappable so the whole app is navigable end to end.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue netWorth = ref.watch(netWorthSummaryProvider);
    final String netWorthValue = netWorth.when(
      data: (summary) => AppFormatters.currencyCompact(summary.netWorth),
      loading: () => '—',
      error: (_, __) => '—',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          GradientCard(
            gradient: AppGradients.gamification,
            onTap: () => context.push('/gamification'),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mortal',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '0 XP · Cultivation begins',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          value: 0.02,
                          minHeight: 6,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your modules',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              ModuleSummaryCard(
                label: 'Net Worth',
                value: netWorthValue,
                subtitle: 'Finance',
                icon: Icons.account_balance_wallet_rounded,
                gradient: AppGradients.finance,
                onTap: () => context.go('/finance'),
              ),
              ModuleSummaryCard(
                label: 'Current workout',
                value: 'No active plan',
                subtitle: 'Fitness',
                icon: Icons.fitness_center_rounded,
                gradient: AppGradients.fitness,
                onTap: () => context.go('/fitness'),
              ),
              ModuleSummaryCard(
                label: 'Habit completion',
                value: '— %',
                subtitle: 'This week',
                icon: Icons.local_fire_department_rounded,
                gradient: AppGradients.habits,
                onTap: () => context.go('/habits'),
              ),
              ModuleSummaryCard(
                label: 'Active goals',
                value: '0',
                subtitle: 'Goals',
                icon: Icons.flag_rounded,
                gradient: AppGradients.goals,
                onTap: () => context.push('/goals'),
              ),
              ModuleSummaryCard(
                label: 'Weekly uploads',
                value: '0 / —',
                subtitle: 'Creator Studio',
                icon: Icons.videocam_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.creatorStudio, const Color(0xFF831843)],
                ),
                onTap: () => context.push('/creator-studio'),
              ),
              ModuleSummaryCard(
                label: 'Currently playing',
                value: 'Nothing yet',
                subtitle: 'Entertainment',
                icon: Icons.movie_filter_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.entertainment, const Color(0xFF4C1D95)],
                ),
                onTap: () => context.push('/entertainment'),
              ),
              ModuleSummaryCard(
                label: 'Today\'s journal',
                value: 'Not written',
                subtitle: 'Journal',
                icon: Icons.menu_book_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.journal, const Color(0xFF115E59)],
                ),
                onTap: () => context.push('/journal'),
              ),
              ModuleSummaryCard(
                label: 'Today\'s schedule',
                value: '0 tasks',
                subtitle: 'Calendar',
                icon: Icons.calendar_month_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.calendar, const Color(0xFF164E63)],
                ),
                onTap: () => context.push('/calendar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
