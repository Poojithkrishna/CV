import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_direction.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class LoansListScreen extends ConsumerWidget {
  const LoansListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Loan>> loansAsync = ref.watch(activeLoansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/loans/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Loan'),
      ),
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Loan> loans) {
          if (loans.isEmpty) {
            return EmptyState(
              icon: Icons.handshake_outlined,
              title: 'No loans yet',
              message: 'Track money you\'ve lent out or borrowed, with partial payments.',
              actionLabel: 'Add your first loan',
              onAction: () => context.push('/finance/loans/new'),
            );
          }

          final List<Loan> given =
              loans.where((l) => l.direction == LoanDirection.given).toList();
          final List<Loan> borrowed =
              loans.where((l) => l.direction == LoanDirection.borrowed).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (given.isNotEmpty) ...[
                _SectionHeader(title: 'Money I\'m owed'),
                for (final Loan loan in given)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LoanTile(
                      loan: loan,
                      onTap: () => context.push('/finance/loans/${loan.id}'),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              if (borrowed.isNotEmpty) ...[
                _SectionHeader(title: 'Money I owe'),
                for (final Loan loan in borrowed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LoanTile(
                      loan: loan,
                      onTap: () => context.push('/finance/loans/${loan.id}'),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
