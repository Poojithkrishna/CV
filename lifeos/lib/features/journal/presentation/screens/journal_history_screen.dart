import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_entry_type.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_entry_card.dart';
import '../../../../app/origin/origin_glyphs.dart';

class JournalHistoryScreen extends ConsumerStatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  ConsumerState<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends ConsumerState<JournalHistoryScreen> {
  JournalEntryType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<JournalEntry>> entriesAsync = ref.watch(allJournalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/entries/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Write'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<JournalEntry> entries) {
          final List<JournalEntry> filtered = entries
              .where((entry) => _typeFilter == null || entry.type == _typeFilter)
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
                      selected: _typeFilter == null,
                      onSelected: (_) => setState(() => _typeFilter = null),
                    ),
                    const SizedBox(width: 8),
                    for (final JournalEntryType type in JournalEntryType.values) ...[
                      ChoiceChip(
                        avatar: Icon(type.icon, size: 16, color: type.color),
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
                      glyph: OriginGlyphType.chronicle,
                        icon: Icons.menu_book_outlined,
                        title: entries.isEmpty ? 'Nothing written yet' : 'Nothing matches this filter',
                        message: entries.isEmpty
                            ? 'Start with a morning journal, a gratitude list, or just free write.'
                            : 'Try a different type filter.',
                        actionLabel: entries.isEmpty ? 'Write your first entry' : null,
                        onAction: entries.isEmpty ? () => context.push('/journal/entries/new') : null,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        children: [
                          for (final JournalEntry entry in filtered)
                            JournalEntryCard(
                              entry: entry,
                              onTap: () => context.push('/journal/entries/${entry.id}/edit'),
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
