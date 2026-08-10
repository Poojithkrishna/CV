import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/clip.dart';
import '../providers/content_studio_providers.dart';
import '../widgets/clip_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class ClipLibraryScreen extends ConsumerWidget {
  const ClipLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Clip>> clipsAsync = ref.watch(allClipsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clip Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/creator-studio/clips/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Clip'),
      ),
      body: clipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Clip> clips) {
          if (clips.isEmpty) {
            return EmptyState(
              icon: Icons.movie_creation_outlined,
              title: 'No clips yet',
              message: 'Save highlights and clips here to build your content from later.',
              actionLabel: 'Add a clip',
              onAction: () => context.push('/creator-studio/clips/new'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: clips.length,
            itemBuilder: (context, index) {
              final Clip clip = clips[index];
              return ClipTile(
                clip: clip,
                onTap: () => context.push('/creator-studio/clips/${clip.id}/edit'),
              );
            },
          );
        },
      ),
    );
  }
}
