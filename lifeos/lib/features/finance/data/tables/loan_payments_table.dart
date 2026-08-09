import 'package:drift/drift.dart';

import 'loans_table.dart';

@DataClassName('LoanPaymentRow')
class LoanPayments extends Table {
  TextColumn get id => text()();

  // See milestones_table.dart in the goals feature for why this uses
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get loanId =>
      text().customConstraint('NOT NULL REFERENCES loans (id) ON DELETE CASCADE')();

  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
