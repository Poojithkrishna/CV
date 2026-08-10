import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/cardio_session.dart';
import '../../domain/services/cardio_stats.dart';
import '../providers/cardio_providers.dart';
import '../widgets/cardio_session_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class CardioListScreen extends ConsumerWidget {
  const CardioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CardioSession>> sessionsAsync = ref.watch(allCardioSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cardio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fitness/cardio/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Session'),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<CardioSession> sessions) {
          if (sessions.isEmpty) {
            return EmptyState(
              icon: Icons.directions_run_rounded,
              title: 'No cardio logged yet',
              message: 'Log a run, ride, swim or any cardio session here.',
              actionLabel: 'Log a session',
              onAction: () => context.push('/fitness/cardio/new'),
            );
          }

          final DateTime now = DateTime.now();
          final DateTime weekAgo = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 6));
          final List<CardioSession> thisWeek = CardioStats.since(sessions, weekAgo);
          final double weekMinutes = CardioStats.totalDurationMinutes(thisWeek);
          final double weekDistance = CardioStats.totalDistanceKm(thisWeek);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'This week', value: '${thisWeek.length} sessions'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Duration', value: '${weekMinutes.toStringAsFixed(0)} min'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Distance', value: '${weekDistance.toStringAsFixed(1)} km'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final CardioSession session in sessions)
                CardioSessionTile(
                  session: session,
                  onTap: () => context.push('/fitness/cardio/${session.id}/edit'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
