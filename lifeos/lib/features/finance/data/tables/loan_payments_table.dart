import 'package:drift/drift.dart';

import 'loans_table.dart';

@DataClassName('LoanPaymentRow')
class LoanPayments extends Table {
  TextColumn get id => text()();

  TextColumn get loanId => text().references(Loans, #id, onDelete: KeyAction.cascade)();

  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
