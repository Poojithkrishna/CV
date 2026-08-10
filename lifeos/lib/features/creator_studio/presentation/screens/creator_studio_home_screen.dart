import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/entities/content_goal.dart';
import '../../domain/entities/content_project.dart';
import '../../domain/services/content_pipeline_stats.dart';
import '../providers/content_studio_providers.dart';
import '../../../../app/origin/origin_glyphs.dart';

const int _recentLimit = 5;
const LinearGradient _gradient = LinearGradient(
  colors: [AppColors.creatorStudio, Color(0xFF1A1A1A)],
);

/// Entry point for the Creator Studio module: weekly upload progress,
/// quick links to the Pipeline board/Clip Library/Analytics, and a peek
/// at recently published projects.
class CreatorStudioHomeScreen extends ConsumerWidget {
  const CreatorStudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ContentProject>> projectsAsync = ref.watch(allContentProjectsProvider);
    final AsyncValue<ContentGoal?> goalAsync = ref.watch(contentGoalProvider);
    final int weeklyTarget = goalAsync.valueOrNull?.weeklyUploadTarget ?? 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Creator Studio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/creator-studio/projects/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Idea'),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<ContentProject> projects) {
          final DateTime now = DateTime.now();
          final DateTime weekAgo = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 6));
          final int uploadsThisWeek = ContentPipelineStats.publishedSince(projects, weekAgo).length;
          final List<ContentProject> recentPublished =
              projects.where((p) => p.isPublished).toList()
                ..sort((a, b) => b.publishedDate!.compareTo(a.publishedDate!));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              GradientCard(
                gradient: _gradient,
                onTap: () => context.push('/creator-studio/analytics'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THIS WEEK',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$uploadsThisWeek / $weeklyTarget uploads',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ToolChip(
                      icon: Icons.view_kanban_outlined,
                      label: 'Pipeline',
                      onTap: () => context.push('/creator-studio/pipeline'),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      icon: Icons.movie_creation_outlined,
                      label: 'Clip Library',
                      onTap: () => context.push('/creator-studio/clips'),
                    ),
                    const SizedBox(width: 8),
                    _ToolChip(
                      icon: Icons.insights_outlined,
                      label: 'Analytics',
                      onTap: () => context.push('/creator-studio/analytics'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently published',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/creator-studio/pipeline'),
                    child: const Text('See pipeline'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentPublished.isEmpty)
                EmptyState(
                  glyph: OriginGlyphType.creator,
                  icon: Icons.videocam_outlined,
                  title: 'Nothing published yet',
                  message: 'Move a project through the pipeline to see it here.',
                  actionLabel: 'Add your first idea',
                  onAction: () => context.push('/creator-studio/projects/new'),
                )
              else
                for (final ContentProject project in recentPublished.take(_recentLimit))
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(project.platform.icon, color: Color(project.colorValue)),
                      title: Text(project.title, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${project.viewCount} views · ${project.likeCount} likes'),
                      onTap: () => context.push('/creator-studio/projects/${project.id}/edit'),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
