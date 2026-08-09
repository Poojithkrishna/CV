import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  final DateTime day = DateTime(2026, 1, 5);

  test('logWater creates an entry on the first log and accumulates after', () async {
    await database.waterDao.logWater(day, 250);
    var entry = await database.waterDao.watchEntryForDate(day).first;
    expect(entry?.amountMl, 250);

    await database.waterDao.logWater(day, 500);
    entry = await database.waterDao.watchEntryForDate(day).first;
    expect(entry?.amountMl, 750);
  });

  test('logWater floors the accumulated total at zero', () async {
    await database.waterDao.logWater(day, 200);
    await database.waterDao.logWater(day, -500);

    final entry = await database.waterDao.watchEntryForDate(day).first;
    expect(entry?.amountMl, 0);
  });

  test('database seeds a default water goal on creation', () async {
    final goal = await database.waterDao.watchGoal().first;
    expect(goal?.dailyGoalMl, 2500);
  });

  test('updateGoal overwrites the singleton goal row', () async {
    await database.waterDao.updateGoal(3000);
    final goal = await database.waterDao.watchGoal().first;
    expect(goal?.dailyGoalMl, 3000);
  });
}
