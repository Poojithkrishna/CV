import 'package:flutter/foundation.dart';

@immutable
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.date,
    required this.startTime,
    required this.createdAt,
    required this.updatedAt,
    this.planId,
    this.dayId,
    this.endTime,
    this.notes,
  });

  final String id;

  /// Null for an ad-hoc workout not tied to any plan.
  final String? planId;
  final String? dayId;

  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInProgress => endTime == null;

  Duration? get duration => endTime?.difference(startTime);

  WorkoutSession copyWith({
    DateTime? endTime,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id,
      planId: planId,
      dayId: dayId,
      date: date,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is WorkoutSession && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
