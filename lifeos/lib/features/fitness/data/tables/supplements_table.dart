import 'package:drift/drift.dart';

@DataClassName('SupplementRow')
class Supplements extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get dosageLabel => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();
  IntColumn get colorValue => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
