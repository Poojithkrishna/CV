import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_entry_type.dart';
import '../../domain/services/journal_stats.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_entry_card.dart';

const int _recentLimit = 5;
const LinearGradient _gradient = LinearGradient(
  colors: [AppColors.journal, Color(0xFF1A1A1A)],
);

/// Entry point for the Journal module: today's streak, one-tap shortcuts
/// for each prompt type, and a peek at recent entries.
class JournalHomeScreen extends ConsumerWidget {
  const JournalHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<JournalEntry>> entriesAsync = ref.watch(allJournalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/entries/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Write'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<JournalEntry> entries) {
          final int streak = JournalStats.currentStreak(entries);
          final double? averageMood = JournalStats.averageMood(entries);
          final List<JournalEntry> recent = entries.take(_recentLimit).toList(growable: false);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              GradientCard(
                gradient: _gradient,
                onTap: () => context.push('/journal/history'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STREAK',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      streak == 1 ? '1 day' : '$streak days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (averageMood != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Average mood ${averageMood.toStringAsFixed(1)} / 5',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final JournalEntryType type in JournalEntryType.values) ...[
                      ActionChip(
                        avatar: Icon(type.icon, size: 18, color: type.color),
                        label: Text(type.label),
                        onPressed: () => context.push('/journal/entries/new', extra: type),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent entries',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/journal/history'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'Nothing written yet',
                  message: 'Start with a morning journal, a gratitude list, or just free write.',
                  actionLabel: 'Write your first entry',
                  onAction: () => context.push('/journal/entries/new'),
                )
              else
                for (final JournalEntry entry in recent)
                  JournalEntryCard(
                    entry: entry,
                    onTap: () => context.push('/journal/entries/${entry.id}/edit'),
                  ),
            ],
          );
        },
      ),
    );
  }
}
