import 'package:flutter/foundation.dart';

@immutable
class LoggedSet {
  const LoggedSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.completedAt,
    this.isWarmup = false,
    this.isPr = false,
  });

  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double weight;
  final bool isWarmup;

  /// Whether this was the heaviest weight ever logged for this exercise
  /// at the time it was logged — see `WorkoutSessionsDao.logSet`.
  final bool isPr;

  final DateTime completedAt;

  /// Working weight moved, excluding warmups (which don't count toward
  /// training volume).
  double get volume => isWarmup ? 0 : reps * weight;

  LoggedSet copyWith({bool? isPr}) {
    return LoggedSet(
      id: id,
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      completedAt: completedAt,
      isWarmup: isWarmup,
      isPr: isPr ?? this.isPr,
    );
  }

  @override
  bool operator ==(Object other) => other is LoggedSet && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
