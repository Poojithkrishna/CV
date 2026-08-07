import 'package:drift/drift.dart';

/// SQLite schema for financial accounts. Stored as a plain SQL table (via
/// Drift) rather than a document store because the Finance module leans
/// heavily on relational queries and aggregates (net worth, per-category
/// spend) once Transactions/Transfers land on top of this table.
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Stored as [AccountType.name] (e.g. `"bank"`, `"creditCard"`).
  TextColumn get accountType => text()();

  RealColumn get currentBalance => real().withDefault(const Constant(0))();
  RealColumn get openingBalance => real().withDefault(const Constant(0))();

  /// ARGB color/gradient theme value chosen by the user.
  IntColumn get colorValue => integer()();

  TextColumn get bankName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  RealColumn get interestRate => real().nullable()();

  /// [IconData.codePoint] of a custom icon, if the user picked one.
  IntColumn get iconCodePoint => integer().nullable()();
  TextColumn get backgroundImagePath => text().nullable()();
  TextColumn get notes => text().nullable()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
