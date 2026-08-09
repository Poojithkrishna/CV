import 'package:drift/drift.dart';

/// Join table linking a goal to habits that contribute to it (e.g. a
/// "Run a marathon" goal linked to a daily "Go for a run" habit). Purely
/// informational — logging the habit doesn't move the goal's own
/// progress, it's just surfaced together on the goal's detail screen.
@DataClassName('GoalHabitLinkRow')
class GoalHabitLinks extends Table {
  // See milestones_table.dart for why these use .customConstraint()
  // instead of .references() — the latter's generated constraint was
  // silently dropped by drift_dev in this schema.
  TextColumn get goalId =>
      text().customConstraint('NOT NULL REFERENCES goals (id) ON DELETE CASCADE')();
  TextColumn get habitId =>
      text().customConstraint('NOT NULL REFERENCES habits (id) ON DELETE CASCADE')();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {goalId, habitId};
}
