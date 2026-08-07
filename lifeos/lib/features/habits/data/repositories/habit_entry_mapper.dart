import '../../../../core/database/app_database.dart';
import '../../domain/entities/habit_entry.dart';

extension HabitEntryRowMapper on HabitEntryRow {
  HabitEntry toDomain() {
    return HabitEntry(
      id: id,
      habitId: habitId,
      periodStart: periodStart,
      progressValue: progressValue,
      checkedItemIndices: _decodeIndices(checkedItemIndices),
      note: note,
      updatedAt: updatedAt,
    );
  }

  static Set<int> _decodeIndices(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    return raw.split(',').map(int.parse).toSet();
  }
}
