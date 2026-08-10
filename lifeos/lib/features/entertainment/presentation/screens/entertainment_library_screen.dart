import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_status.dart';
import '../../domain/entities/media_type.dart';
import '../providers/media_library_providers.dart';
import '../widgets/media_item_card.dart';
import '../../../../app/origin/origin_glyphs.dart';

class EntertainmentLibraryScreen extends ConsumerStatefulWidget {
  const EntertainmentLibraryScreen({super.key});

  @override
  ConsumerState<EntertainmentLibraryScreen> createState() => _EntertainmentLibraryScreenState();
}

class _EntertainmentLibraryScreenState extends ConsumerState<EntertainmentLibraryScreen> {
  MediaStatus? _statusFilter;
  MediaType? _typeFilter;

  Future<void> _logProgress(MediaItem item) async {
    await ref.read(logMediaProgressUseCaseProvider).call(item.id, 1);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<MediaItem>> itemsAsync = ref.watch(allMediaItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/entertainment/items/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Add'),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<MediaItem> items) {
          final List<MediaItem> filtered = items
              .where((item) => _statusFilter == null || item.status == _statusFilter)
              .where((item) => _typeFilter == null || item.type == _typeFilter)
              .toList(growable: false);

          return Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    for (final MediaStatus status in MediaStatus.values) ...[
                      ChoiceChip(
                        label: Text(status.label),
                        selected: _statusFilter == status,
                        onSelected: (_) => setState(
                          () => _statusFilter = _statusFilter == status ? null : status,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final MediaType type in MediaType.values) ...[
                      ChoiceChip(
                        avatar: Icon(type.icon, size: 16),
                        label: Text(type.label),
                        selected: _typeFilter == type,
                        onSelected: (_) => setState(
                          () => _typeFilter = _typeFilter == type ? null : type,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.local_movies_outlined,
                        title: items.isEmpty ? 'Your library is empty' : 'Nothing matches these filters',
                        message: items.isEmpty
                            ? 'Add a game, movie, series, book or course to start tracking it.'
                            : 'Try a different type or status filter.',
                        actionLabel: items.isEmpty ? 'Add your first item' : null,
                        onAction: items.isEmpty ? () => context.push('/entertainment/items/new') : null,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        children: [
                          for (final MediaItem item in filtered)
                            MediaItemCard(
                              item: item,
                              onTap: () => context.push('/entertainment/items/${item.id}/edit'),
                              onLogProgress:
                                  item.totalProgress != null ? () => _logProgress(item) : null,
                            ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
