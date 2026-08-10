import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/asset.dart';
import '../providers/asset_providers.dart';
import '../widgets/asset_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class AssetsListScreen extends ConsumerWidget {
  const AssetsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Asset>> assetsAsync = ref.watch(activeAssetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/assets/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Asset'),
      ),
      body: assetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Asset> assets) {
          if (assets.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.wealth,
              icon: Icons.inventory_2_outlined,
              title: 'No assets yet',
              message: 'Track real estate, vehicles, jewelry and other valuables here.',
              actionLabel: 'Add your first asset',
              onAction: () => context.push('/finance/assets/new'),
            );
          }

          final double totalValue = assets.fold<double>(0, (sum, a) => sum + a.currentValue);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                    Text('Total value', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(totalValue),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final Asset asset in assets)
                AssetTile(
                  asset: asset,
                  onTap: () => context.push('/finance/assets/${asset.id}/edit'),
                ),
            ],
          );
        },
      ),
    );
  }
}
