import 'package:drift/drift.dart';

import 'goals_table.dart';

@DataClassName('MilestoneRow')
class Milestones extends Table {
  TextColumn get id => text()();
  // drift_dev 2.31.0's `.references(Goals, #id, ...)` resolver fails to
  // recognize `Goals` as a class-literal identifier in this project's
  // multi-file schema (a real drift_dev parsing quirk — it warns "This
  // parameter should be a simple class name" and then silently omits
  // the constraint from the generated schema entirely, so the cascade
  // never actually fired). Written as raw SQL via `.customConstraint()`
  // instead, which sidesteps that resolution path altogether.
  TextColumn get goalId =>
      text().customConstraint('NOT NULL REFERENCES goals (id) ON DELETE CASCADE')();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  DateTimeColumn get targetDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
