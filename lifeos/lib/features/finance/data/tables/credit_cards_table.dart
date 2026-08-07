import 'package:drift/drift.dart';

@DataClassName('CreditCardRow')
class CreditCards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get bankName => text().nullable()();

  RealColumn get creditLimit => real()();

  /// Amount currently owed; adjusted via the card's charge/payment
  /// quick-actions rather than a full transaction ledger.
  RealColumn get currentUsage => real().withDefault(const Constant(0))();

  IntColumn get statementDay => integer().nullable()();
  IntColumn get dueDay => integer().nullable()();

  IntColumn get rewardPoints => integer().withDefault(const Constant(0))();
  RealColumn get cashbackEarned => real().withDefault(const Constant(0))();
  RealColumn get annualFee => real().nullable()();

  IntColumn get colorValue => integer()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
