import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/habits/domain/entities/habit.dart';
import 'package:lifeos/features/habits/domain/entities/habit_entry.dart';
import 'package:lifeos/features/habits/domain/entities/habit_frequency.dart';
import 'package:lifeos/features/habits/domain/entities/habit_type.dart';
import 'package:lifeos/features/habits/domain/repositories/habit_repository.dart';
import 'package:lifeos/features/habits/domain/usecases/create_habit.dart';

class _FakeHabitRepository implements HabitRepository {
  Habit? savedHabit;

  @override
  Future<Result<Habit>> createHabit(Habit habit) async {
    savedHabit = habit;
    return Result.ok(habit);
  }

  @override
  Future<Result<void>> deleteHabit(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> logProgress(String habitId, DateTime periodStart, double delta) async =>
      const Result.ok(null);

  @override
  Future<Result<void>> toggleChecklistItem(
    String habitId,
    DateTime periodStart,
    int itemIndex,
  ) async =>
      const Result.ok(null);

  @override
  Future<Result<Habit>> updateHabit(Habit habit) async => Result.ok(habit);

  @override
  Stream<Habit?> watchHabit(String id) => const Stream.empty();

  @override
  Stream<List<Habit>> watchActiveHabits() => const Stream.empty();

  @override
  Stream<List<HabitEntry>> watchEntriesForHabit(String habitId) => const Stream.empty();

  @override
  Stream<HabitEntry?> watchEntryForPeriod(String habitId, DateTime periodStart) =>
      const Stream.empty();
}

Habit _buildHabit({
  HabitType type = HabitType.counter,
  double targetValue = 10,
  List<String> checklistItems = const [],
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Habit(
    id: 'habit-1',
    name: 'Drink water',
    type: type,
    frequency: HabitFrequency.daily,
    targetValue: targetValue,
    checklistItems: checklistItems,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateHabit', () {
    test('persists a valid numeric habit', () async {
      final repo = _FakeHabitRepository();
      final useCase = CreateHabit(repo);

      final result = await useCase(_buildHabit());

      expect(result.isOk, isTrue);
      expect(repo.savedHabit?.name, 'Drink water');
    });

    test('rejects a blank name', () async {
      final repo = _FakeHabitRepository();
      final useCase = CreateHabit(repo);

      final result = await useCase(_buildHabit().copyWith(name: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedHabit, isNull);
    });

    test('rejects a numeric habit with a zero target', () async {
      final repo = _FakeHabitRepository();
      final useCase = CreateHabit(repo);

      final result = await useCase(_buildHabit(targetValue: 0));

      expect(result.isErr, isTrue);
      expect(repo.savedHabit, isNull);
    });

    test('rejects a checklist habit with no items', () async {
      final repo = _FakeHabitRepository();
      final useCase = CreateHabit(repo);

      final result = await useCase(_buildHabit(type: HabitType.checklist, checklistItems: const []));

      expect(result.isErr, isTrue);
      expect(repo.savedHabit, isNull);
    });

    test('accepts a checklist habit with at least one item', () async {
      final repo = _FakeHabitRepository();
      final useCase = CreateHabit(repo);

      final result = await useCase(
        _buildHabit(type: HabitType.checklist, checklistItems: const ['Stretch']),
      );

      expect(result.isOk, isTrue);
    });
  });
}
