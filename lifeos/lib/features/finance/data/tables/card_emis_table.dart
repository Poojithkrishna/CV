import 'package:drift/drift.dart';

import 'credit_cards_table.dart';

@DataClassName('CardEmiRow')
class CardEmis extends Table {
  TextColumn get id => text()();

  TextColumn get cardId =>
      text().references(CreditCards, #id, onDelete: KeyAction.cascade)();

  TextColumn get description => text().withLength(min: 1, max: 120)();
  RealColumn get totalAmount => real()();
  RealColumn get monthlyAmount => real()();
  IntColumn get tenureMonths => integer()();
  IntColumn get monthsPaid => integer().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
