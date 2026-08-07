import 'package:drift/drift.dart';

@DataClassName('LoanRow')
class Loans extends Table {
  TextColumn get id => text()();

  /// Stored as [LoanDirection.name] (`"given"` / `"borrowed"`).
  TextColumn get direction => text()();

  TextColumn get personName => text().withLength(min: 1, max: 80)();
  TextColumn get personPhone => text().nullable()();

  RealColumn get principalAmount => real()();
  RealColumn get remainingAmount => real()();

  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();

  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
