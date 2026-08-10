import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_status.dart';
import '../../domain/services/media_library_stats.dart';
import '../providers/media_library_providers.dart';
import '../widgets/media_item_card.dart';

const int _sectionLimit = 5;
const LinearGradient _gradient = LinearGradient(
  colors: [AppColors.entertainment, Color(0xFF1A1A1A)],
);

/// Entry point for the Entertainment module: what's currently in
/// progress, a quick link to the full Library, and a peek at what was
/// recently completed. Reachable both as its own route (deep links, widget
/// taps) and embedded as Chronicle's Media section (see
/// [EntertainmentHomeBody]).
class EntertainmentHomeScreen extends StatelessWidget {
  const EntertainmentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entertainment')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/entertainment/items/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: const EntertainmentHomeBody(),
    );
  }
}

class EntertainmentHomeBody extends ConsumerWidget {
  const EntertainmentHomeBody({super.key});

  Future<void> _logProgress(WidgetRef ref, MediaItem item) async {
    await ref.read(logMediaProgressUseCaseProvider).call(item.id, 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MediaItem>> itemsAsync = ref.watch(allMediaItemsProvider);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Something went wrong: $error')),
      data: (List<MediaItem> items) {
        final Map<MediaStatus, int> byStatus = MediaLibraryStats.countByStatus(items);
        final List<MediaItem> inProgress =
            items.where((item) => item.status == MediaStatus.inProgress).toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final List<MediaItem> recentlyCompleted =
            items.where((item) => item.status == MediaStatus.completed).toList()
              ..sort((a, b) => b.completedDate!.compareTo(a.completedDate!));

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            GradientCard(
              gradient: _gradient,
              onTap: () => context.push('/entertainment/library'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${byStatus[MediaStatus.inProgress]} items',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${byStatus[MediaStatus.wishlist]} wishlisted · '
                    '${byStatus[MediaStatus.completed]} completed',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ActionChip(
              avatar: const Icon(Icons.video_library_outlined, size: 18),
              label: const Text('Browse full library'),
              onPressed: () => context.push('/entertainment/library'),
            ),
            const SizedBox(height: 20),
            Text(
              'Continue',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (inProgress.isEmpty)
              EmptyState(
                icon: Icons.play_circle_outline_rounded,
                title: 'Nothing in progress',
                message: 'Mark something as In Progress to see it here.',
                actionLabel: 'Add your first item',
                onAction: () => context.push('/entertainment/items/new'),
              )
            else
              for (final MediaItem item in inProgress.take(_sectionLimit))
                MediaItemCard(
                  item: item,
                  onTap: () => context.push('/entertainment/items/${item.id}/edit'),
                  onLogProgress:
                      item.totalProgress != null ? () => _logProgress(ref, item) : null,
                ),
            if (recentlyCompleted.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Recently completed',
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final MediaItem item in recentlyCompleted.take(_sectionLimit))
                MediaItemCard(
                  item: item,
                  onTap: () => context.push('/entertainment/items/${item.id}/edit'),
                ),
            ],
          ],
        );
      },
    );
  }
}
