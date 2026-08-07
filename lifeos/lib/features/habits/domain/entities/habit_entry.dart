import 'package:flutter/foundation.dart';

import 'habit.dart';
import 'habit_type.dart';

/// One period's worth of progress for a [Habit] — normalized `periodStart`
/// is the unique key per habit (see `HabitsDao.logProgress`).
@immutable
class HabitEntry {
  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.periodStart,
    required this.updatedAt,
    this.progressValue = 0,
    this.checkedItemIndices = const {},
    this.note,
  });

  final String id;
  final String habitId;
  final DateTime periodStart;
  final double progressValue;

  /// Indices into `Habit.checklistItems` that are checked off this period.
  final Set<int> checkedItemIndices;

  final String? note;
  final DateTime updatedAt;

  bool isCompleteFor(Habit habit) {
    if (habit.type == HabitType.checklist) {
      return habit.checklistItems.isNotEmpty &&
          checkedItemIndices.length >= habit.checklistItems.length;
    }
    return progressValue >= habit.targetValue;
  }

  HabitEntry copyWith({
    double? progressValue,
    Set<int>? checkedItemIndices,
    String? note,
    bool clearNote = false,
    DateTime? updatedAt,
  }) {
    return HabitEntry(
      id: id,
      habitId: habitId,
      periodStart: periodStart,
      progressValue: progressValue ?? this.progressValue,
      checkedItemIndices: checkedItemIndices ?? this.checkedItemIndices,
      note: clearNote ? null : (note ?? this.note),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is HabitEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
