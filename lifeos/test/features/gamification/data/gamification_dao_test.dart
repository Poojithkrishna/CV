import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (db) => db.execute('PRAGMA foreign_keys = ON;')),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('watchUnlockedAchievements is empty until something is unlocked', () async {
    expect(await database.gamificationDao.watchUnlockedAchievements().first, isEmpty);
  });

  test('unlockAchievement records the key', () async {
    await database.gamificationDao.unlockAchievement('rich_cultivator');

    final unlocked = await database.gamificationDao.watchUnlockedAchievements().first;

    expect(unlocked.map((row) => row.key), ['rich_cultivator']);
  });

  test('unlockAchievement never re-unlocks or overwrites the original unlockedAt', () async {
    await database.gamificationDao.unlockAchievement('iron_body');
    final first = await database.gamificationDao.watchUnlockedAchievements().first;
    final DateTime originalUnlockedAt = first.single.unlockedAt;

    await database.gamificationDao.unlockAchievement('iron_body');
    final second = await database.gamificationDao.watchUnlockedAchievements().first;

    expect(second.length, 1);
    expect(second.single.unlockedAt, originalUnlockedAt);
  });

  test('unlocking multiple distinct achievements keeps all of them', () async {
    await database.gamificationDao.unlockAchievement('rich_cultivator');
    await database.gamificationDao.unlockAchievement('iron_body');

    final unlocked = await database.gamificationDao.watchUnlockedAchievements().first;

    expect(unlocked.map((row) => row.key), containsAll(['rich_cultivator', 'iron_body']));
  });
}
