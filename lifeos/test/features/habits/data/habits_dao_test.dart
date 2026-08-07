import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/habits/data/repositories/habit_entry_mapper.dart';
import 'package:lifeos/features/habits/data/repositories/habit_mapper.dart';
import 'package:lifeos/features/habits/domain/entities/habit.dart';
import 'package:lifeos/features/habits/domain/entities/habit_frequency.dart';
import 'package:lifeos/features/habits/domain/entities/habit_type.dart';

Habit _buildHabit({
  String id = 'h1',
  HabitType type = HabitType.counter,
  double targetValue = 10,
  List<String> checklistItems = const [],
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Habit(
    id: id,
    name: 'Habit $id',
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
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  final DateTime period = DateTime(2026, 1, 5);

  test('logProgress creates an entry on the first log and accumulates after', () async {
    await database.habitsDao.insertHabit(_buildHabit().toCompanion());

    await database.habitsDao.logProgress('h1', period, 3);
    var entry = await database.habitsDao.watchEntryForPeriod('h1', period).first;
    expect(entry?.progressValue, 3);

    await database.habitsDao.logProgress('h1', period, 4);
    entry = await database.habitsDao.watchEntryForPeriod('h1', period).first;
    expect(entry?.progressValue, 7);
  });

  test('logProgress floors the accumulated value at zero', () async {
    await database.habitsDao.insertHabit(_buildHabit().toCompanion());

    await database.habitsDao.logProgress('h1', period, 2);
    await database.habitsDao.logProgress('h1', period, -5);

    final entry = await database.habitsDao.watchEntryForPeriod('h1', period).first;
    expect(entry?.progressValue, 0);
  });

  test('toggleChecklistItem checks and unchecks an item for the period', () async {
    await database.habitsDao.insertHabit(
      _buildHabit(type: HabitType.checklist, checklistItems: const ['A', 'B']).toCompanion(),
    );

    await database.habitsDao.toggleChecklistItem('h1', period, 1);
    var entry = await database.habitsDao.watchEntryForPeriod('h1', period).first;
    expect(entry?.toDomain().checkedItemIndices, {1});

    await database.habitsDao.toggleChecklistItem('h1', period, 0);
    entry = await database.habitsDao.watchEntryForPeriod('h1', period).first;
    expect(entry?.toDomain().checkedItemIndices, {0, 1});

    await database.habitsDao.toggleChecklistItem('h1', period, 1);
    entry = await database.habitsDao.watchEntryForPeriod('h1', period).first;
    expect(entry?.toDomain().checkedItemIndices, {0});
  });
}
