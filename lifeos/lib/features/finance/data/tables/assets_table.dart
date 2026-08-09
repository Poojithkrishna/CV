import 'package:drift/drift.dart';

@DataClassName('AssetRow')
class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Stored as [AssetType.name].
  TextColumn get type => text()();

  /// Current estimated value — what actually counts toward net worth.
  RealColumn get currentValue => real().withDefault(const Constant(0))();

  /// What it cost originally, kept only for reference (not used in any
  /// calculation) — null if unknown.
  RealColumn get purchasePrice => real().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();

  TextColumn get notes => text().nullable()();
  IntColumn get colorValue => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
