import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/content_project.dart';
import '../../domain/entities/content_stage.dart';
import '../providers/content_studio_providers.dart';
import '../widgets/content_project_card.dart';

const double _columnWidth = 260;

class ContentPipelineScreen extends ConsumerWidget {
  const ContentPipelineScreen({super.key});

  Future<void> _move(WidgetRef ref, ContentProject project, ContentStage? stage) async {
    if (stage == null) return;
    await ref.read(moveProjectToStageUseCaseProvider).call(project, stage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ContentProject>> projectsAsync = ref.watch(allContentProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pipeline')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/creator-studio/projects/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Idea'),
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<ContentProject> projects) {
          final Map<ContentStage, List<ContentProject>> byStage = {
            for (final ContentStage stage in ContentStage.values)
              stage: projects.where((p) => p.stage == stage).toList(),
          };

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final ContentStage stage in ContentStage.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: _columnWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(stage.icon, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                stage.label,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${byStage[stage]!.length}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (final ContentProject project in byStage[stage]!)
                            ContentProjectCard(
                              project: project,
                              onTap: () => context.push('/creator-studio/projects/${project.id}/edit'),
                              onMoveBack: stage.previous == null
                                  ? null
                                  : () => _move(ref, project, stage.previous),
                              onMoveForward: stage.next == null
                                  ? null
                                  : () => _move(ref, project, stage.next),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
