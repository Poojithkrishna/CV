import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../../../core/widgets/trend_line_chart.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/attribute.dart';
import '../../domain/entities/gamification_snapshot.dart';
import '../../domain/entities/life_score_snapshot.dart';
import '../../domain/entities/rank.dart';
import '../../domain/entities/unlocked_achievement.dart';
import '../providers/gamification_providers.dart';
import '../providers/last_seen_rank_provider.dart';
import '../widgets/achievement_badge.dart';

/// The Gamification home screen: current rank and XP progress, the
/// eight attributes derived live from every other module, an overall
/// Life Score, and the achievement grid. Nothing here is user-editable
/// — it's a read-only reflection of what's already been logged
/// elsewhere in the app.
class GamificationHomeScreen extends ConsumerWidget {
  const GamificationHomeScreen({super.key});

  void _celebrateNewlyUnlocked(
    BuildContext context,
    WidgetRef ref,
    Set<String> satisfiedKeys,
    Set<String> alreadyUnlockedKeys,
  ) {
    final Set<String> newlyUnlocked = satisfiedKeys.difference(alreadyUnlockedKeys);
    if (newlyUnlocked.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final String key in newlyUnlocked) {
        ref.read(unlockAchievementUseCaseProvider).call(key);
        final Achievement achievement = achievementCatalog.firstWhere((a) => a.key == key);
        if (!context.mounted) continue;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(achievement.icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Achievement unlocked: ${achievement.title}')),
              ],
            ),
          ),
        );
      }
    });
  }

  /// Shows a one-time celebration dialog the first time each rank is
  /// reached. [lastSeenRankIndex] is `null` until loaded from disk, in
  /// which case nothing fires yet — the next rebuild after loading will
  /// catch up correctly.
  void _checkRankUp(BuildContext context, WidgetRef ref, Rank rank, int? lastSeenRankIndex) {
    if (lastSeenRankIndex == null || rank.index <= lastSeenRankIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(lastSeenRankProvider.notifier).markSeen(rank.index);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(rank.icon, size: 40),
          title: Text('Ascended to ${rank.label}'),
          content: Text(rank.flavorTitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    });
  }

  /// Records today's Life Score/XP/rank so the history chart has
  /// something to plot. Idempotent within a day — see
  /// `GamificationDao.upsertTodaysSnapshot`.
  void _recordTodaysSnapshot(WidgetRef ref, GamificationSnapshot snapshot) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recordLifeScoreSnapshotUseCaseProvider).call(
            lifeScore: snapshot.lifeScore,
            xp: snapshot.xp,
            rank: snapshot.rank,
          );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<GamificationSnapshot> snapshotAsync = ref.watch(gamificationSnapshotProvider);
    final AsyncValue<List<UnlockedAchievement>> unlockedAsync = ref.watch(unlockedAchievementsProvider);
    final AsyncValue<List<LifeScoreSnapshot>> historyAsync = ref.watch(lifeScoreSnapshotsProvider);
    final int? lastSeenRankIndex = ref.watch(lastSeenRankProvider);

    final GamificationSnapshot? snapshot = snapshotAsync.valueOrNull;
    final List<UnlockedAchievement>? unlocked = unlockedAsync.valueOrNull;
    final List<LifeScoreSnapshot> history = historyAsync.valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Demon God Cultivation')),
      body: snapshot == null || unlocked == null
          ? (snapshotAsync.hasError
              ? Center(child: Text('Something went wrong: ${snapshotAsync.error}'))
              : const Center(child: CircularProgressIndicator()))
          : _buildBody(context, ref, snapshot, unlocked, history, lastSeenRankIndex),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    GamificationSnapshot snapshot,
    List<UnlockedAchievement> unlocked,
    List<LifeScoreSnapshot> history,
    int? lastSeenRankIndex,
  ) {
    final Set<String> unlockedKeys = unlocked.map((u) => u.key).toSet();
    _celebrateNewlyUnlocked(context, ref, snapshot.satisfiedAchievementKeys, unlockedKeys);
    _checkRankUp(context, ref, snapshot.rank, lastSeenRankIndex);
    _recordTodaysSnapshot(ref, snapshot);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        GradientCard(
          gradient: AppGradients.gamification,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(snapshot.rank.icon, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.rank.label,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          snapshot.rank.flavorTitle,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${snapshot.xp} XP',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LabeledProgressBar(
                progress: snapshot.progressToNextRank,
                leadingLabel: snapshot.rank.next == null
                    ? 'Max rank reached'
                    : 'Progress to ${snapshot.rank.next!.label}',
                trailingLabel: '${(snapshot.progressToNextRank * 100).toStringAsFixed(0)}%',
                color: Colors.white,
                trackColor: Colors.white24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.insights_outlined),
                const SizedBox(width: 12),
                const Text('Life Score', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(
                  snapshot.lifeScore.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Text(' / 100'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _LifeScoreHistoryCard(history: history),
        const SizedBox(height: 24),
        Text(
          'Attributes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        for (final Attribute attribute in Attribute.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LabeledProgressBar(
              progress: (snapshot.attributes[attribute] ?? 0) / 100,
              leadingLabel: attribute.label,
              trailingLabel: (snapshot.attributes[attribute] ?? 0).toStringAsFixed(0),
              color: attribute.color,
            ),
          ),
        const SizedBox(height: 12),
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        for (final AchievementCategory category in AchievementCategory.values)
          _AchievementCategorySection(
            category: category,
            achievements: achievementCatalog.where((a) => a.category == category).toList(),
            unlockedKeys: unlockedKeys,
          ),
      ],
    );
  }
}

/// A day-by-day trend of Life Score, built from whatever was recorded
/// each time the app was open (see `_recordTodaysSnapshot`) — there's no
/// background recomputation, so a sparse history just means the app
/// wasn't opened those days, the same honesty as the home screen
/// widget's freshness.
class _LifeScoreHistoryCard extends StatelessWidget {
  const _LifeScoreHistoryCard({required this.history});

  final List<LifeScoreSnapshot> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded),
                const SizedBox(width: 12),
                Text('Life Score History', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            if (history.length < 2)
              Text(
                'Open the app on a few different days to start seeing your '
                'Life Score trend here.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              TrendLineChart(
                valuesAscending: [for (final LifeScoreSnapshot s in history) s.lifeScore],
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// One section of the achievement grid — a category header followed by
/// every achievement belonging to it.
class _AchievementCategorySection extends StatelessWidget {
  const _AchievementCategorySection({
    required this.category,
    required this.achievements,
    required this.unlockedKeys,
  });

  final AchievementCategory category;
  final List<Achievement> achievements;
  final Set<String> unlockedKeys;

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) return const SizedBox.shrink();
    final int unlockedCount = achievements.where((a) => unlockedKeys.contains(a.key)).length;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '$unlockedCount / ${achievements.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              for (final Achievement achievement in achievements)
                AchievementBadge(
                  achievement: achievement,
                  isUnlocked: unlockedKeys.contains(achievement.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
