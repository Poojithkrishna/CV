import 'package:drift/drift.dart';

@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  TextColumn get id => text()();

  /// Stored as [JournalEntryType.name].
  TextColumn get type => text()();

  DateTimeColumn get date => dateTime()();
  TextColumn get content => text()();

  /// Stored as [Mood.name], nullable — not every entry has a mood logged.
  TextColumn get mood => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
