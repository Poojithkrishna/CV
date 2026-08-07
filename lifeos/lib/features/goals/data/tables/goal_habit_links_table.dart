import 'package:drift/drift.dart';

import '../../../habits/data/tables/habits_table.dart';
import 'goals_table.dart';

/// Join table linking a goal to habits that contribute to it (e.g. a
/// "Run a marathon" goal linked to a daily "Go for a run" habit). Purely
/// informational — logging the habit doesn't move the goal's own
/// progress, it's just surfaced together on the goal's detail screen.
@DataClassName('GoalHabitLinkRow')
class GoalHabitLinks extends Table {
  TextColumn get goalId =>
      text().references(Goals, #id, onDelete: KeyAction.cascade)();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {goalId, habitId};
}
