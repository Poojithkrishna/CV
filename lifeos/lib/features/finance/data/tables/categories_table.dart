import 'package:drift/drift.dart';

/// SQLite schema for transaction categories (e.g. "Food", "Salary").
/// Categories are scoped to a single [CategoryType] (income or expense) so
/// the category picker in the transaction form only ever shows relevant
/// options.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Stored as [CategoryType.name] (`"income"` / `"expense"`).
  TextColumn get type => text()();

  /// Key into the curated icon catalog (see `CategoryIcons` in the
  /// presentation layer) rather than a raw icon code point, so seed data
  /// doesn't depend on hardcoding font glyph numbers.
  TextColumn get iconKey => text().nullable()();

  /// ARGB color used for the category's icon/chip.
  IntColumn get colorValue => integer()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
