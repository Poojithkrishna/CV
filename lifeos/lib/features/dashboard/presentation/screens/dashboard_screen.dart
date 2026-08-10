import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/origin/origin_colors.dart';
import '../../../../app/origin/origin_glyphs.dart';
import '../../../../app/origin/origin_panel.dart';
import '../../../../app/origin/origin_progress.dart';
import '../../../../app/origin/origin_rows.dart';
import '../../../../app/origin/origin_spacing.dart';
import '../../../../app/origin/origin_typography.dart';
import '../../../../core/home_widget/home_widget_data.dart';
import '../../../../core/providers/home_widget_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/brand_wordmark.dart';
import '../../../../core/widgets/radial_gauge.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/domain/entities/calendar_task.dart';
import '../../../calendar/domain/services/calendar_stats.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../entertainment/domain/entities/media_item.dart';
import '../../../entertainment/domain/entities/media_status.dart';
import '../../../entertainment/presentation/providers/media_library_providers.dart';
import '../../../finance/presentation/providers/net_worth_provider.dart';
import '../../../gamification/domain/entities/attribute.dart';
import '../../../gamification/domain/entities/gamification_snapshot.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/presentation/providers/journal_providers.dart';

/// Sanctuary (spec §7) — Demon Origin's command center, not a grid of
/// module tiles. One hero panel: Origin rank/progress, Today's Rite (what
/// matters right now, drawn from today's pending calendar tasks), Origin
/// Balance (the real eight cultivation attributes, not the spec mockup's
/// illustrative five — see note below), and Recent Ascent (a light,
/// real-data activity glance, not a fabricated timeline). Deep analytics
/// stay inside each module; this screen answers "what matters today" in
/// about five seconds.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<GamificationSnapshot> gamificationSnapshot =
        ref.watch(gamificationSnapshotProvider);
    final AsyncValue<List<CalendarTask>> calendarTasks = ref.watch(allTasksProvider);
    final AsyncValue<List<CalendarEvent>> calendarEvents = ref.watch(allEventsProvider);
    final AsyncValue netWorth = ref.watch(netWorthSummaryProvider);
    final AsyncValue<double> habitCompletion = ref.watch(habitsWeeklyCompletionProvider);
    final AsyncValue<List<Goal>> activeGoals = ref.watch(activeGoalsProvider);
    final AsyncValue<List<MediaItem>> mediaItems = ref.watch(allMediaItemsProvider);
    final AsyncValue<List<JournalEntry>> journalEntries = ref.watch(allJournalEntriesProvider);

    final String netWorthValue = netWorth.when(
      data: (summary) => AppFormatters.currencyCompact(summary.netWorth),
      loading: () => '—',
      error: (_, __) => '—',
    );
    final String habitCompletionValue = habitCompletion.when(
      data: (rate) => '${(rate * 100).toStringAsFixed(0)}%',
      loading: () => '—',
      error: (_, __) => '—',
    );
    final String todaysScheduleValue = calendarTasks.hasValue && calendarEvents.hasValue
        ? '${CalendarStats.tasksOnDate(calendarTasks.value!, DateTime.now()).length + CalendarStats.eventsOnDate(calendarEvents.value!, DateTime.now()).length} today'
        : '—';

    // Keeps the Android home screen widget in sync with whatever Sanctuary
    // itself is showing — there's no background refresh, so "whenever the
    // user has the app open" is what freshness means here, the same as
    // every other piece of this app being purely on-device with no push
    // mechanism of its own.
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
            icon: OriginGlyph(OriginGlyphType.settings, size: 22, color: OriginColors.textSecondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          OriginPanel(
            hero: true,
            onTap: () => context.push('/gamification'),
            child: gamificationSnapshot.when(
              data: (snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RadialGauge(
                        value: snapshot.progressToNextRank,
                        size: 72,
                        strokeWidth: 4,
                        trackColor: OriginColors.hairline,
                        valueColor: OriginColors.violet,
                        child: OriginGlyph(
                          OriginGlyphType.sanctuary,
                          size: 30,
                          color: OriginColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: OriginSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.rank.label.toUpperCase(),
                                style: OriginTypography.heading(size: 20)),
                            Text(snapshot.rank.flavorTitle,
                                style: TextStyle(
                                  fontFamily: OriginTypography.body,
                                  fontSize: 13,
                                  color: OriginColors.textSecondary,
                                )),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('${snapshot.xp} XP',
                                    style: OriginTypography.figure(size: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OriginProgress(value: snapshot.progressToNextRank),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const OriginDivider(),
                  Text('TODAY\'S RITE', style: OriginTypography.eyebrow()),
                  const SizedBox(height: OriginSpacing.sm),
                  _TodaysRite(tasks: calendarTasks.valueOrNull),
                  const OriginDivider(),
                  Text('ORIGIN BALANCE', style: OriginTypography.eyebrow()),
                  const SizedBox(height: OriginSpacing.sm),
                  _OriginBalance(attributes: snapshot.attributes),
                  const OriginDivider(),
                  Text('RECENT ASCENT', style: OriginTypography.eyebrow()),
                  const SizedBox(height: OriginSpacing.sm),
                  _RecentAscent(
                    activeGoalsCount: activeGoals.valueOrNull?.length,
                    inProgressMedia: mediaItems.valueOrNull
                        ?.where((item) => item.status == MediaStatus.inProgress)
                        .toList(),
                    wroteJournalToday: journalEntries.valueOrNull?.any((entry) {
                      final DateTime now = DateTime.now();
                      return entry.date.year == now.year &&
                          entry.date.month == now.month &&
                          entry.date.day == now.day;
                    }),
                    habitCompletionPercent: habitCompletion.valueOrNull,
                  ),
                ],
              ),
              loading: () => const SizedBox(
                height: 72,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Text(
                'Origin state unavailable',
                style: TextStyle(color: OriginColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's Rite — the day's pending calendar tasks, at most four, in
/// priority (due-soonest) order. An empty install shows an elegant
/// invitation rather than a blank list (spec §7/§16).
class _TodaysRite extends StatelessWidget {
  const _TodaysRite({required this.tasks});

  final List<CalendarTask>? tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks == null) {
      return const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    final List<CalendarTask> today = CalendarStats.tasksOnDate(tasks!, DateTime.now())
        .where((t) => !t.isDone)
        .toList()
      ..sort((a, b) {
        final DateTime? aDue = a.dueDate;
        final DateTime? bDue = b.dueDate;
        if (aDue == null || bDue == null) return 0;
        return aDue.compareTo(bDue);
      });

    if (today.isEmpty) {
      return _QuietLine(
        text: 'No rites bound to today — Sanctuary is quiet.',
        onTap: () => context.push('/chronicle'),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < today.take(4).length; i++)
          RitualRow(
            index: i + 1,
            label: today[i].title,
            onTap: () => context.push('/calendar/tasks/${today[i].id}/edit'),
          ),
      ],
    );
  }
}

/// Origin Balance — the eight real cultivation attributes
/// (`GamificationStats.computeAttributes`, each derived from another
/// module's live data), each rendered as a labeled band. The spec's
/// mockup shows five illustrative bands (Body/Wealth/Mind/Spirit/
/// Creation); mapping the app's actual eight attributes onto those five
/// labels would be an arbitrary, lossy regrouping, so this shows all
/// eight real ones instead — same visual language, real data.
class _OriginBalance extends StatelessWidget {
  const _OriginBalance({required this.attributes});

  final Map<Attribute, double> attributes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final Attribute attribute in Attribute.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 78,
                  child: Text(
                    attribute.label.toUpperCase(),
                    style: OriginTypography.eyebrow(size: 11),
                  ),
                ),
                Expanded(
                  child: OriginProgress(value: (attributes[attribute] ?? 0) / 100),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Recent Ascent — a light glance built from signals Sanctuary already
/// has on hand, not a fabricated activity log. A real cross-module
/// timeline (spec §15's Chronicle) is a data-layer feature for a later
/// pass; this is deliberately modest until that exists.
class _RecentAscent extends StatelessWidget {
  const _RecentAscent({
    required this.activeGoalsCount,
    required this.inProgressMedia,
    required this.wroteJournalToday,
    required this.habitCompletionPercent,
  });

  final int? activeGoalsCount;
  final List<MediaItem>? inProgressMedia;
  final bool? wroteJournalToday;
  final double? habitCompletionPercent;

  @override
  Widget build(BuildContext context) {
    final List<String> lines = [];
    if (wroteJournalToday == true) lines.add('A journal entry was written today.');
    if (inProgressMedia != null && inProgressMedia!.isNotEmpty) {
      lines.add('Continuing "${inProgressMedia!.first.title}".');
    }
    if (habitCompletionPercent != null && habitCompletionPercent! > 0) {
      lines.add('${(habitCompletionPercent! * 100).round()}% of habits held this week.');
    }
    if (activeGoalsCount != null && activeGoalsCount! > 0) {
      lines.add('$activeGoalsCount standard${activeGoalsCount == 1 ? '' : 's'} still in motion.');
    }

    if (lines.isEmpty) {
      return const _QuietLine(text: 'Nothing to report yet — the order awaits your first move.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final String line in lines.take(3))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ',
                    style: TextStyle(color: OriginColors.textSecondary, fontFamily: OriginTypography.body)),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      fontFamily: OriginTypography.body,
                      fontSize: 13,
                      color: OriginColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuietLine extends StatelessWidget {
  const _QuietLine({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: OriginTypography.body,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: OriginColors.textSecondary,
        ),
      ),
    );
  }
}
