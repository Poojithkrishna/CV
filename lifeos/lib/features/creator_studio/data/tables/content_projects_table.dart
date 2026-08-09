import 'package:drift/drift.dart';

@DataClassName('ContentProjectRow')
class ContentProjects extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  TextColumn get game => text().withDefault(const Constant(''))();

  /// Stored as [ContentPlatform.name].
  TextColumn get platform => text()();

  /// Stored as [ContentStage.name].
  TextColumn get stage => text()();

  TextColumn get notes => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get publishedDate => dateTime().nullable()();

  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  IntColumn get likeCount => integer().withDefault(const Constant(0))();
  IntColumn get commentCount => integer().withDefault(const Constant(0))();

  IntColumn get colorValue => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
