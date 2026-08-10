import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_providers.dart';
import '../widgets/credit_card_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class CreditCardsListScreen extends ConsumerWidget {
  const CreditCardsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CreditCard>> cardsAsync = ref.watch(activeCreditCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Credit Cards')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/credit-cards/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Card'),
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<CreditCard> cards) {
          if (cards.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.wealth,
              icon: Icons.credit_card_outlined,
              title: 'No credit cards yet',
              message: 'Add a card to track its limit, usage and due dates.',
              actionLabel: 'Add your first card',
              onAction: () => context.push('/finance/credit-cards/new'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final CreditCard card = cards[index];
              return CreditCardTile(
                card: card,
                onTap: () => context.push('/finance/credit-cards/${card.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
