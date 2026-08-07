import 'package:flutter/foundation.dart';

import 'workout_plan_type.dart';

@immutable
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.isActive = false,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final WorkoutPlanType type;
  final String? notes;

  /// Only one plan is active at a time — see
  /// `WorkoutPlansDao.setActivePlan`.
  final bool isActive;

  final bool isArchived;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutPlan copyWith({
    String? name,
    WorkoutPlanType? type,
    String? notes,
    bool clearNotes = false,
    bool? isActive,
    bool? isArchived,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      notes: clearNotes ? null : (notes ?? this.notes),
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is WorkoutPlan && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
