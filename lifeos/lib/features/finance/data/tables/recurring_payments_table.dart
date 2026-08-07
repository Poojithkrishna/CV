import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

@DataClassName('RecurringPaymentRow')
class RecurringPayments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  RealColumn get amount => real()();

  /// Stored as [RecurrenceFrequency.name].
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();

  TextColumn get categoryId =>
      text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();

  /// Left null if this bill isn't tracked against a specific account
  /// (e.g. paid in cash) — "mark as paid" then just advances the
  /// schedule instead of logging a transaction.
  TextColumn get accountId =>
      text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();

  IntColumn get reminderDaysBefore => integer().nullable()();
  BoolColumn get isAutoPay => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get colorValue => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
