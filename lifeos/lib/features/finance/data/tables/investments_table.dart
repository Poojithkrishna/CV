import 'package:drift/drift.dart';

@DataClassName('InvestmentRow')
class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Stored as [InvestmentType.name].
  TextColumn get type => text()();

  /// Total amount put in — the cost basis used for gain/loss.
  RealColumn get investedAmount => real().withDefault(const Constant(0))();

  /// Current market value, kept up to date by the user (no live price
  /// feed — this is an offline app).
  RealColumn get currentValue => real().withDefault(const Constant(0))();

  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get colorValue => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
