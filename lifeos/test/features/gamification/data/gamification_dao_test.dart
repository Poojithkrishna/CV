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

  group('life score snapshots', () {
    final DateTime today = DateTime(2026, 1, 10);
    final DateTime yesterday = DateTime(2026, 1, 9);

    test('watchLifeScoreSnapshots is empty until something is recorded', () async {
      expect(await database.gamificationDao.watchLifeScoreSnapshots().first, isEmpty);
    });

    test('upsertTodaysSnapshot inserts a new row for a new date', () async {
      await database.gamificationDao.upsertTodaysSnapshot(
        id: 's1',
        date: today,
        lifeScore: 42,
        xp: 3400,
        rankIndex: 3,
      );

      final rows = await database.gamificationDao.watchLifeScoreSnapshots().first;

      expect(rows, hasLength(1));
      expect(rows.single.date, today);
      expect(rows.single.lifeScore, 42);
      expect(rows.single.xp, 3400);
      expect(rows.single.rankIndex, 3);
    });

    test('upsertTodaysSnapshot updates the existing row for the same date instead of duplicating', () async {
      await database.gamificationDao.upsertTodaysSnapshot(
        id: 's1',
        date: today,
        lifeScore: 42,
        xp: 3400,
        rankIndex: 3,
      );
      await database.gamificationDao.upsertTodaysSnapshot(
        id: 's2',
        date: today,
        lifeScore: 55,
        xp: 3600,
        rankIndex: 3,
      );

      final rows = await database.gamificationDao.watchLifeScoreSnapshots().first;

      expect(rows, hasLength(1));
      expect(rows.single.lifeScore, 55);
      expect(rows.single.xp, 3600);
    });

    test('recording snapshots on different dates keeps both, ordered ascending by date', () async {
      await database.gamificationDao.upsertTodaysSnapshot(
        id: 's1',
        date: today,
        lifeScore: 60,
        xp: 4000,
        rankIndex: 3,
      );
      await database.gamificationDao.upsertTodaysSnapshot(
        id: 's2',
        date: yesterday,
        lifeScore: 50,
        xp: 3500,
        rankIndex: 3,
      );

      final rows = await database.gamificationDao.watchLifeScoreSnapshots().first;

      expect(rows.map((r) => r.date), [yesterday, today]);
    });
  });
}
