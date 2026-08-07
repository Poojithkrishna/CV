import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/logged_set.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/services/workout_stats.dart';
import '../providers/workout_session_providers.dart';

class SessionHistoryTile extends ConsumerWidget {
  const SessionHistoryTile({super.key, required this.session, this.onTap});

  final WorkoutSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LoggedSet>> setsAsync = ref.watch(setsForSessionProvider(session.id));
    final List<LoggedSet> sets = setsAsync.valueOrNull ?? const [];
    final Duration? duration = session.duration;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Icon(
            session.isInProgress ? Icons.play_arrow_rounded : Icons.check_rounded,
            size: 20,
          ),
        ),
        title: Text(AppFormatters.shortDate(session.date)),
        subtitle: Text(
          session.isInProgress
              ? 'In progress'
              : '${sets.length} sets · ${duration != null ? '${duration.inMinutes} min' : ''}',
        ),
        trailing: Text(
          '${WorkoutStats.sessionVolume(sets).toStringAsFixed(0)}kg',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
