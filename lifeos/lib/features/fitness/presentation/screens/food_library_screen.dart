import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/food_item.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_item_tile.dart';

class FoodLibraryScreen extends ConsumerWidget {
  const FoodLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FoodItem>> itemsAsync = ref.watch(activeFoodItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fitness/nutrition/foods/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Food'),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<FoodItem> items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.restaurant_outlined,
              title: 'No foods here yet',
              message: 'Add a food to build your library.',
              actionLabel: 'Add a food',
              onAction: () => context.push('/fitness/nutrition/foods/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final FoodItem item = items[index];
              return FoodItemTile(
                item: item,
                onTap: () => context.push('/fitness/nutrition/foods/${item.id}/edit'),
              );
            },
          );
        },
      ),
    );
  }
}
