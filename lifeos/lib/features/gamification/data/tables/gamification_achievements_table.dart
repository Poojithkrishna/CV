import 'package:drift/drift.dart';

/// One row per unlocked achievement, keyed by the achievement's static
/// catalog `key` (see `achievement.dart`) rather than a generated id,
/// since a given achievement can only ever be unlocked once.
@DataClassName('UnlockedAchievementRow')
class GamificationAchievements extends Table {
  TextColumn get key => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
