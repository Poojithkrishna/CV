import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';

extension HabitRowMapper on HabitRow {
  Habit toDomain() {
    return Habit(
      id: id,
      name: name,
      type: HabitType.values.byName(type),
      frequency: HabitFrequency.values.byName(frequency),
      targetValue: targetValue,
      unit: unit,
      customWeekdays: _decodeWeekdays(customWeekdays),
      checklistItems: _decodeChecklist(checklistItems),
      notes: notes,
      isArchived: isArchived,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Set<int> _decodeWeekdays(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    return raw.split(',').map(int.parse).toSet();
  }

  static List<String> _decodeChecklist(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw.split('\n');
  }
}

extension HabitEntityMapper on Habit {
  HabitsCompanion toCompanion() {
    return HabitsCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      frequency: frequency.name,
      targetValue: Value(targetValue),
      unit: Value(unit),
      customWeekdays: Value(customWeekdays.isEmpty ? null : customWeekdays.join(',')),
      checklistItems: Value(checklistItems.isEmpty ? null : checklistItems.join('\n')),
      notes: Value(notes),
      isArchived: Value(isArchived),
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
