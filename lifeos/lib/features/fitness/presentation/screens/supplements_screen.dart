import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/supplement.dart';
import '../providers/supplement_providers.dart';
import '../widgets/supplement_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class SupplementsScreen extends ConsumerWidget {
  const SupplementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Supplement>> supplementsAsync = ref.watch(activeSupplementsProvider);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(title: const Text('Supplements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fitness/supplements/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Supplement'),
      ),
      body: supplementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Supplement> supplements) {
          if (supplements.isEmpty) {
            return EmptyState(
              icon: Icons.medication_outlined,
              title: 'No supplements yet',
              message: 'Add the vitamins and supplements you take regularly.',
              actionLabel: 'Add your first supplement',
              onAction: () => context.push('/fitness/supplements/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: supplements.length,
            itemBuilder: (context, index) {
              final Supplement supplement = supplements[index];
              return SupplementTile(
                supplement: supplement,
                date: today,
                onTap: () => context.push('/fitness/supplements/${supplement.id}/edit'),
              );
            },
          );
        },
      ),
    );
  }
}
