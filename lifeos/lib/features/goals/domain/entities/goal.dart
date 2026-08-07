import 'package:flutter/foundation.dart';

/// A long-running objective, optionally broken into [Milestone]s and
/// optionally linked to habits that contribute to it. When a goal has no
/// milestones, progress is tracked directly via [progressValue] against
/// [targetValue] — the same numeric model used by counter-type habits.
@immutable
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.targetDate,
    this.progressValue = 0,
    this.targetValue = 1,
    this.isArchived = false,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? targetDate;
  final double progressValue;
  final double targetValue;
  final int colorValue;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    DateTime? targetDate,
    bool clearTargetDate = false,
    double? progressValue,
    double? targetValue,
    int? colorValue,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      progressValue: progressValue ?? this.progressValue,
      targetValue: targetValue ?? this.targetValue,
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Goal && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
