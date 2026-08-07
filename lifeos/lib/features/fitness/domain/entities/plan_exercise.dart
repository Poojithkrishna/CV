import 'package:flutter/foundation.dart';

/// One exercise entry within a [WorkoutDay], with its targets. This is
/// the template a workout session is logged against — see
/// `LoggedSet` for the actual performed sets.
@immutable
class PlanExercise {
  const PlanExercise({
    required this.id,
    required this.dayId,
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    required this.createdAt,
    required this.updatedAt,
    this.targetWeight,
    this.restSeconds,
    this.sortOrder = 0,
    this.notes,
  });

  final String id;
  final String dayId;
  final String exerciseId;
  final int targetSets;

  /// Free-form so it can express a range, e.g. `"8-12"`.
  final String targetReps;

  final double? targetWeight;
  final int? restSeconds;
  final int sortOrder;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanExercise copyWith({
    int? targetSets,
    String? targetReps,
    double? targetWeight,
    bool clearTargetWeight = false,
    int? restSeconds,
    bool clearRestSeconds = false,
    int? sortOrder,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return PlanExercise(
      id: id,
      dayId: dayId,
      exerciseId: exerciseId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: clearTargetWeight ? null : (targetWeight ?? this.targetWeight),
      restSeconds: clearRestSeconds ? null : (restSeconds ?? this.restSeconds),
      sortOrder: sortOrder ?? this.sortOrder,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is PlanExercise && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
