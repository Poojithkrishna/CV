import 'package:flutter/foundation.dart';

/// A single checkpoint towards a [Goal]. When a goal has any milestones,
/// its overall progress is the fraction of milestones completed — see
/// `GoalStats.progress`.
@immutable
class Milestone {
  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
    this.isCompleted = false,
  });

  final String id;
  final String goalId;
  final String title;
  final DateTime? targetDate;
  final bool isCompleted;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Milestone copyWith({
    String? title,
    DateTime? targetDate,
    bool clearTargetDate = false,
    bool? isCompleted,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return Milestone(
      id: id,
      goalId: goalId,
      title: title ?? this.title,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Milestone && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
