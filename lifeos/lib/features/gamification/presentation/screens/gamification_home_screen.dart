import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/attribute.dart';
import '../../domain/entities/gamification_snapshot.dart';
import '../../domain/entities/unlocked_achievement.dart';
import '../providers/gamification_providers.dart';
import '../widgets/achievement_badge.dart';

/// The Gamification home screen: current rank and XP progress, the
/// eight attributes derived live from every other module, an overall
/// Life Score, and the achievement grid. Nothing here is user-editable
/// — it's a read-only reflection of what's already been logged
/// elsewhere in the app.
class GamificationHomeScreen extends ConsumerWidget {
  const GamificationHomeScreen({super.key});

  void _unlockNewlySatisfied(WidgetRef ref, Set<String> satisfiedKeys, Set<String> alreadyUnlockedKeys) {
    final Set<String> newlyUnlocked = satisfiedKeys.difference(alreadyUnlockedKeys);
    if (newlyUnlocked.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final String key in newlyUnlocked) {
        ref.read(unlockAchievementUseCaseProvider).call(key);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<GamificationSnapshot> snapshotAsync = ref.watch(gamificationSnapshotProvider);
    final AsyncValue<List<UnlockedAchievement>> unlockedAsync = ref.watch(unlockedAchievementsProvider);

    final GamificationSnapshot? snapshot = snapshotAsync.valueOrNull;
    final List<UnlockedAchievement>? unlocked = unlockedAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Demon God Cultivation')),
      body: snapshot == null || unlocked == null
          ? (snapshotAsync.hasError
              ? Center(child: Text('Something went wrong: ${snapshotAsync.error}'))
              : const Center(child: CircularProgressIndicator()))
          : _buildBody(context, ref, snapshot, unlocked),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    GamificationSnapshot snapshot,
    List<UnlockedAchievement> unlocked,
  ) {
    final Set<String> unlockedKeys = unlocked.map((u) => u.key).toSet();
    _unlockNewlySatisfied(ref, snapshot.satisfiedAchievementKeys, unlockedKeys);

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
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            for (final Achievement achievement in achievementCatalog)
              AchievementBadge(
                achievement: achievement,
                isUnlocked: unlockedKeys.contains(achievement.key),
              ),
          ],
        ),
      ],
    );
  }
}
