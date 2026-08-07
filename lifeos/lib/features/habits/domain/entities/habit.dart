import 'package:flutter/foundation.dart';

import 'habit_frequency.dart';
import 'habit_type.dart';

@immutable
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.frequency,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.targetValue = 1,
    this.unit,
    this.customWeekdays = const {},
    this.checklistItems = const [],
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final HabitType type;
  final HabitFrequency frequency;

  /// What counts as "done" for one period — ignored for [HabitType.checklist]
  /// (derived from `checklistItems.length` instead) and defaulted to `1`
  /// for [HabitType.yesNo], where it's really just a boolean toggle.
  final double targetValue;

  /// Free-form label for the target, e.g. "glasses", "minutes", "pages".
  final String? unit;

  /// Days of the week (1 = Monday .. 7 = Sunday) this habit is scheduled
  /// on — only meaningful when [frequency] is [HabitFrequency.custom].
  final Set<int> customWeekdays;

  /// Template checklist item labels — only meaningful for
  /// [HabitType.checklist]; each period's completion is tracked
  /// separately per `HabitEntry.checkedItemIndices`.
  final List<String> checklistItems;

  final String? notes;
  final bool isArchived;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isScheduledOn(DateTime date) {
    if (frequency != HabitFrequency.custom) return true;
    if (customWeekdays.isEmpty) return true;
    return customWeekdays.contains(date.weekday);
  }

  Habit copyWith({
    String? name,
    HabitType? type,
    HabitFrequency? frequency,
    double? targetValue,
    String? unit,
    bool clearUnit = false,
    Set<int>? customWeekdays,
    List<String>? checklistItems,
    String? notes,
    bool clearNotes = false,
    bool? isArchived,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      unit: clearUnit ? null : (unit ?? this.unit),
      customWeekdays: customWeekdays ?? this.customWeekdays,
      checklistItems: checklistItems ?? this.checklistItems,
      notes: clearNotes ? null : (notes ?? this.notes),
      isArchived: isArchived ?? this.isArchived,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Habit && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
