import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/habits/domain/entities/habit.dart';
import 'package:lifeos/features/habits/domain/entities/habit_entry.dart';
import 'package:lifeos/features/habits/domain/entities/habit_frequency.dart';
import 'package:lifeos/features/habits/domain/entities/habit_type.dart';
import 'package:lifeos/features/habits/domain/services/habit_stats.dart';

Habit _dailyHabit({HabitFrequency frequency = HabitFrequency.daily}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Habit(
    id: 'h1',
    name: 'Drink water',
    type: HabitType.yesNo,
    frequency: frequency,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

HabitEntry _entry(DateTime periodStart, {double progressValue = 1}) {
  return HabitEntry(
    id: 'e-${periodStart.toIso8601String()}',
    habitId: 'h1',
    periodStart: periodStart,
    progressValue: progressValue,
    updatedAt: periodStart,
  );
}

void main() {
  group('HabitStats.currentStreak', () {
    test('counts consecutive completed days ending yesterday, with today in progress', () {
      final habit = _dailyHabit();
      final DateTime today = DateTime(2026, 1, 10);
      final completed = {
        DateTime(2026, 1, 9),
        DateTime(2026, 1, 8),
        DateTime(2026, 1, 7),
      };

      final streak = HabitStats.currentStreak(
        habit: habit,
        completedPeriods: completed,
        asOf: today,
      );

      expect(streak, 3);
    });

    test('does not break the streak for an incomplete current period', () {
      final habit = _dailyHabit();
      final DateTime today = DateTime(2026, 1, 10);
      final completed = {DateTime(2026, 1, 9)};

      final streak = HabitStats.currentStreak(
        habit: habit,
        completedPeriods: completed,
        asOf: today,
      );

      expect(streak, 1);
    });

    test('breaks on a missed period further back', () {
      final habit = _dailyHabit();
      final DateTime today = DateTime(2026, 1, 10);
      final completed = {
        DateTime(2026, 1, 9),
        // 8th missing
        DateTime(2026, 1, 7),
      };

      final streak = HabitStats.currentStreak(
        habit: habit,
        completedPeriods: completed,
        asOf: today,
      );

      expect(streak, 1);
    });

    test('skips unscheduled custom days without breaking the streak', () {
      final now = DateTime(2026, 1, 1);
      final habit = Habit(
        id: 'h2',
        name: 'Gym',
        type: HabitType.yesNo,
        frequency: HabitFrequency.custom,
        customWeekdays: const {1, 3, 5}, // Mon, Wed, Fri
        colorValue: 0xFF7C4DFF,
        createdAt: now,
        updatedAt: now,
      );

      // Wed 7th, Mon 5th completed; Fri is not scheduled between them isn't
      // relevant here — Sat/Sun/Tue/Thu are simply not scheduled days.
      final DateTime asOf = DateTime(2026, 1, 8); // Thursday
      final completed = {
        DateTime(2026, 1, 7), // Wed
        DateTime(2026, 1, 5), // Mon
      };

      final streak = HabitStats.currentStreak(
        habit: habit,
        completedPeriods: completed,
        asOf: asOf,
      );

      expect(streak, 2);
    });
  });

  group('HabitStats.longestStreak', () {
    test('returns zero when nothing was ever completed', () {
      final habit = _dailyHabit();
      expect(HabitStats.longestStreak(habit: habit, completedPeriods: const {}), 0);
    });

    test('finds the longest run anywhere in history, not just the latest', () {
      final habit = _dailyHabit();
      final completed = {
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 4),
        // gap
        DateTime(2026, 1, 10),
        DateTime(2026, 1, 11),
      };

      expect(HabitStats.longestStreak(habit: habit, completedPeriods: completed), 4);
    });
  });

  group('HabitStats.completionRate', () {
    test('returns the fraction of scheduled periods completed', () {
      final habit = _dailyHabit();
      final completed = {
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 3),
      };

      final rate = HabitStats.completionRate(
        habit: habit,
        completedPeriods: completed,
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 4),
      );

      expect(rate, 0.5);
    });

    test('returns zero when there is nothing scheduled in range', () {
      final now = DateTime(2026, 1, 1);
      final habit = Habit(
        id: 'h3',
        name: 'Custom',
        type: HabitType.yesNo,
        frequency: HabitFrequency.custom,
        customWeekdays: const {1},
        colorValue: 0xFF7C4DFF,
        createdAt: now,
        updatedAt: now,
      );
      // A range with no Mondays in it at all isn't realistic for a single
      // day, so use `from == to` on a non-Monday.
      final rate = HabitStats.completionRate(
        habit: habit,
        completedPeriods: const {},
        from: DateTime(2026, 1, 7), // Wednesday
        to: DateTime(2026, 1, 7),
      );
      expect(rate, 0);
    });
  });

  group('HabitStats.heatmapData', () {
    test('gives partial credit for numeric habits based on progress ratio', () {
      final now = DateTime(2026, 1, 1);
      final habit = Habit(
        id: 'h4',
        name: 'Push-ups',
        type: HabitType.counter,
        frequency: HabitFrequency.daily,
        targetValue: 20,
        colorValue: 0xFF7C4DFF,
        createdAt: now,
        updatedAt: now,
      );
      final entries = [_entry(DateTime(2026, 1, 1), progressValue: 10)];

      final data = HabitStats.heatmapData(
        habit: habit,
        entries: entries,
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 1),
      );

      expect(data[DateTime(2026, 1, 1)], 0.5);
    });

    test('is zero for a period with no entry', () {
      final habit = _dailyHabit();
      final data = HabitStats.heatmapData(
        habit: habit,
        entries: const [],
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 1),
      );
      expect(data[DateTime(2026, 1, 1)], 0);
    });
  });
}
