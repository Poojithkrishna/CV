import 'package:flutter/foundation.dart';

/// A named session within a plan (e.g. "Push Day", "Day 1") — the unit
/// you actually pick when starting a workout.
@immutable
class WorkoutDay {
  const WorkoutDay({
    required this.id,
    required this.planId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  final String id;
  final String planId;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutDay copyWith({
    String? name,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return WorkoutDay(
      id: id,
      planId: planId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is WorkoutDay && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
