import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/content_goal.dart';
import '../../domain/entities/content_project.dart';
import '../../domain/entities/content_stage.dart';
import '../../domain/services/content_pipeline_stats.dart';
import '../providers/content_studio_providers.dart';

const Color _accentColor = AppColors.creatorStudio;

class ContentAnalyticsScreen extends ConsumerWidget {
  const ContentAnalyticsScreen({super.key});

  Future<void> _editGoal(BuildContext context, WidgetRef ref, int currentTarget) async {
    final double? target = await showAmountInputDialog(
      context,
      title: 'Weekly upload goal',
      label: 'Uploads per week',
      initialValue: currentTarget.toDouble(),
    );
    if (target == null) return;
    final result = await ref.read(updateContentGoalUseCaseProvider).call(target.round());
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ContentProject>> projectsAsync = ref.watch(allContentProjectsProvider);
    final AsyncValue<ContentGoal?> goalAsync = ref.watch(contentGoalProvider);
    final int weeklyTarget = goalAsync.valueOrNull?.weeklyUploadTarget ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Weekly goal',
            onPressed: () => _editGoal(context, ref, weeklyTarget),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<ContentProject> projects) {
          final DateTime now = DateTime.now();
          final DateTime weekAgo = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 6));
          final List<ContentProject> publishedThisWeek =
              ContentPipelineStats.publishedSince(projects, weekAgo);
          final List<ContentProject> published =
              projects.where((p) => p.isPublished).toList(growable: false);
          final Map<ContentStage, int> byStage = ContentPipelineStats.countByStage(projects);
          final int maxStageCount = byStage.values.fold(0, (a, b) => a > b ? a : b);
          final int totalViews = ContentPipelineStats.totalViews(published);
          final int totalLikes = ContentPipelineStats.totalLikes(published);
          final int totalComments = ContentPipelineStats.totalComments(published);
          final double avgViews = ContentPipelineStats.averageViews(published);
          final double weeklyProgress = weeklyTarget <= 0
              ? 0
              : (publishedThisWeek.length / weeklyTarget).clamp(0, 1).toDouble();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                    Text('This week', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${publishedThisWeek.length} / $weeklyTarget uploads',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    LabeledProgressBar(
                      progress: weeklyProgress,
                      leadingLabel: '${(weeklyProgress * 100).toStringAsFixed(0)}%',
                      trailingLabel: 'of weekly goal',
                      color: _accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Total views', value: '$totalViews')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Total likes', value: '$totalLikes')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Avg. views', value: avgViews.toStringAsFixed(0))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Total comments', value: '$totalComments'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Published', value: '${published.length}'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Pipeline breakdown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final ContentStage stage in ContentStage.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LabeledProgressBar(
                    progress: maxStageCount == 0 ? 0 : byStage[stage]! / maxStageCount,
                    leadingLabel: stage.label,
                    trailingLabel: '${byStage[stage]}',
                    color: _accentColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
