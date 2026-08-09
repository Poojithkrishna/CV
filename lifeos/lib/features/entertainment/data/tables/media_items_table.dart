import 'package:drift/drift.dart';

@DataClassName('MediaItemRow')
class MediaItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();

  /// Stored as [MediaType.name].
  TextColumn get type => text()();

  /// Stored as [MediaStatus.name].
  TextColumn get status => text()();

  IntColumn get currentProgress => integer().withDefault(const Constant(0))();
  IntColumn get totalProgress => integer().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get notes => text().nullable()();

  /// Path to a cover image copied into the app's own documents directory
  /// via `core/utils/photo_storage.dart` — see the Creator Studio and
  /// Fitness Progress Photos features for the same pattern.
  TextColumn get coverImagePath => text().nullable()();

  DateTimeColumn get startedDate => dateTime().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  IntColumn get colorValue => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
