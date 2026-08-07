import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/workout_session.dart';
import '../providers/workout_session_providers.dart';

final Uuid _uuid = Uuid();

/// Creates a new [WorkoutSession] (optionally against a plan/day) and
/// immediately swaps itself for the real session screen — a thin
/// redirect so the session-screen route always has a concrete id to
/// watch, rather than juggling a nullable "not started yet" state there.
class StartWorkoutScreen extends ConsumerStatefulWidget {
  const StartWorkoutScreen({super.key, this.planId, this.dayId});

  final String? planId;
  final String? dayId;

  @override
  ConsumerState<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends ConsumerState<StartWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final DateTime now = DateTime.now();
    final WorkoutSession session = WorkoutSession(
      id: _uuid.v4(),
      planId: widget.planId,
      dayId: widget.dayId,
      date: now,
      startTime: now,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(startWorkoutSessionUseCaseProvider).call(session);
    if (!mounted) return;

    result.when(
      ok: (started) => context.pushReplacement('/fitness/workouts/${started.id}'),
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
