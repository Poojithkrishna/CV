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

  // See milestones_table.dart in the goals feature for why these use
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get categoryId =>
      text().nullable().customConstraint('REFERENCES categories (id) ON DELETE SET NULL')();

  /// Left null if this bill isn't tracked against a specific account
  /// (e.g. paid in cash) — "mark as paid" then just advances the
  /// schedule instead of logging a transaction.
  TextColumn get accountId =>
      text().nullable().customConstraint('REFERENCES accounts (id) ON DELETE SET NULL')();

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
