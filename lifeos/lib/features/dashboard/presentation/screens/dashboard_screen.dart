import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_gradients.dart';
import '../../../../core/home_widget/home_widget_data.dart';
import '../../../../core/providers/home_widget_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../creator_studio/domain/entities/content_goal.dart';
import '../../../creator_studio/domain/entities/content_project.dart';
import '../../../creator_studio/domain/services/content_pipeline_stats.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/domain/entities/calendar_task.dart';
import '../../../calendar/domain/services/calendar_stats.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../creator_studio/presentation/providers/content_studio_providers.dart';
import '../../../entertainment/domain/entities/media_item.dart';
import '../../../entertainment/domain/entities/media_status.dart';
import '../../../entertainment/presentation/providers/media_library_providers.dart';
import '../../../finance/presentation/providers/net_worth_provider.dart';
import '../../../fitness/presentation/providers/workout_plan_providers.dart';
import '../../../gamification/domain/entities/gamification_snapshot.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/presentation/providers/journal_providers.dart';
import '../widgets/module_summary_card.dart';

/// The Demon Origin home screen: a single glance at every module. Every module
/// summary tile, and the cultivation card's rank/XP/progress, are wired
/// to real data derived live from what's actually been logged — nothing
/// on this screen is a placeholder anymore.
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

    final AsyncValue activePlan = ref.watch(currentActivePlanProvider);
    final String activePlanValue = activePlan.when(
      data: (plan) => plan?.name ?? 'No active plan',
      loading: () => '—',
      error: (_, __) => '—',
    );

    final AsyncValue<double> habitCompletion = ref.watch(habitsWeeklyCompletionProvider);
    final String habitCompletionValue = habitCompletion.when(
      data: (rate) => '${(rate * 100).toStringAsFixed(0)}%',
      loading: () => '—',
      error: (_, __) => '—',
    );

    final AsyncValue<List<Goal>> activeGoals = ref.watch(activeGoalsProvider);
    final String activeGoalsValue = activeGoals.when(
      data: (goals) => '${goals.length}',
      loading: () => '—',
      error: (_, __) => '—',
    );

    final AsyncValue<List<ContentProject>> contentProjects = ref.watch(allContentProjectsProvider);
    final AsyncValue<ContentGoal?> contentGoal = ref.watch(contentGoalProvider);
    final String weeklyUploadsValue = contentProjects.when(
      data: (projects) {
        final DateTime now = DateTime.now();
        final DateTime weekAgo =
            DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        final int uploads = ContentPipelineStats.publishedSince(projects, weekAgo).length;
        final int target = contentGoal.valueOrNull?.weeklyUploadTarget ?? 1;
        return '$uploads / $target';
      },
      loading: () => '—',
      error: (_, __) => '—',
    );

    final AsyncValue<List<MediaItem>> mediaItems = ref.watch(allMediaItemsProvider);
    final String currentlyPlayingValue = mediaItems.when(
      data: (items) {
        final List<MediaItem> inProgress =
            items.where((item) => item.status == MediaStatus.inProgress).toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return inProgress.isEmpty ? 'Nothing yet' : inProgress.first.title;
      },
      loading: () => '—',
      error: (_, __) => '—',
    );

    final AsyncValue<List<JournalEntry>> journalEntries = ref.watch(allJournalEntriesProvider);
    final String journalValue = journalEntries.when(
      data: (entries) {
        final DateTime now = DateTime.now();
        final bool writtenToday = entries.any(
          (entry) =>
              entry.date.year == now.year &&
              entry.date.month == now.month &&
              entry.date.day == now.day,
        );
        return writtenToday ? 'Written' : 'Not written';
      },
      loading: () => '—',
      error: (_, __) => '—',
    );

    final AsyncValue<List<CalendarTask>> calendarTasks = ref.watch(allTasksProvider);
    final AsyncValue<List<CalendarEvent>> calendarEvents = ref.watch(allEventsProvider);
    final String todaysScheduleValue = calendarTasks.hasValue && calendarEvents.hasValue
        ? '${CalendarStats.tasksOnDate(calendarTasks.value!, DateTime.now()).length + CalendarStats.eventsOnDate(calendarEvents.value!, DateTime.now()).length} today'
        : '—';

    final AsyncValue<GamificationSnapshot> gamificationSnapshot =
        ref.watch(gamificationSnapshotProvider);

    // Keeps the Android home screen widget in sync with whatever the
    // dashboard itself is showing — there's no background refresh, so
    // "whenever the user has the app open" is what freshness means
    // here, the same as every other piece of this app being purely
    // on-device with no push mechanism of its own.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeWidgetSyncServiceProvider).push(
            buildHomeWidgetData(
              gamificationSnapshot: gamificationSnapshot.valueOrNull,
              netWorthValue: netWorthValue,
              habitCompletionValue: habitCompletionValue,
              scheduleSummary: todaysScheduleValue,
            ),
          );
    });

    return Scaffold(
      appBar: AppBar(
        title: const BrandLockup(),
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
          Container(
            // Ambient glow behind the rank/XP hero card — the first thing
            // seen on launch, so it's the highest-leverage spot for the
            // "lit from within" premium feel.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppGradients.glowShadow(AppColors.gamification),
            ),
            child: GradientCard(
              gradient: AppGradients.gamification,
              onTap: () => context.push('/gamification'),
              child: gamificationSnapshot.when(
                data: (snapshot) => Row(
                  children: [
                    Icon(snapshot.rank.icon, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.rank.label,
                            style:
                                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${snapshot.xp} XP · ${snapshot.rank.flavorTitle}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: snapshot.progressToNextRank,
                              minHeight: 6,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 36),
                    SizedBox(width: 16),
                    Expanded(child: Text('Loading cultivation progress…')),
                  ],
                ),
                error: (_, __) => const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 36),
                    SizedBox(width: 16),
                    Expanded(child: Text('Cultivation progress unavailable')),
                  ],
                ),
              ),
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
                onTap: () => context.go('/finance'),
              ),
              ModuleSummaryCard(
                label: 'Current workout',
                value: activePlanValue,
                subtitle: 'Fitness',
                icon: Icons.fitness_center_rounded,
                onTap: () => context.go('/fitness'),
              ),
              ModuleSummaryCard(
                label: 'Habit completion',
                value: habitCompletionValue,
                subtitle: 'This week',
                icon: Icons.local_fire_department_rounded,
                onTap: () => context.go('/habits'),
              ),
              ModuleSummaryCard(
                label: 'Active goals',
                value: activeGoalsValue,
                subtitle: 'Goals',
                icon: Icons.flag_rounded,
                onTap: () => context.push('/goals'),
              ),
              ModuleSummaryCard(
                label: 'Weekly uploads',
                value: weeklyUploadsValue,
                subtitle: 'Creator Studio',
                icon: Icons.videocam_rounded,
                onTap: () => context.push('/creator-studio'),
              ),
              ModuleSummaryCard(
                label: 'Currently playing',
                value: currentlyPlayingValue,
                subtitle: 'Entertainment',
                icon: Icons.movie_filter_rounded,
                onTap: () => context.push('/entertainment'),
              ),
              ModuleSummaryCard(
                label: 'Today\'s journal',
                value: journalValue,
                subtitle: 'Journal',
                icon: Icons.menu_book_rounded,
                onTap: () => context.push('/journal'),
              ),
              ModuleSummaryCard(
                label: 'Today\'s schedule',
                value: todaysScheduleValue,
                subtitle: 'Calendar',
                icon: Icons.calendar_month_rounded,
                onTap: () => context.push('/calendar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
