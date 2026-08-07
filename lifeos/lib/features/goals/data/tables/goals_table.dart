import 'package:drift/drift.dart';

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();

  RealColumn get progressValue => real().withDefault(const Constant(0))();
  RealColumn get targetValue => real().withDefault(const Constant(1))();

  IntColumn get colorValue => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
