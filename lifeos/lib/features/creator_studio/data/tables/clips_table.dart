import 'package:drift/drift.dart';

import 'content_projects_table.dart';

@DataClassName('ClipRow')
class Clips extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  TextColumn get game => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();

  /// Optional — which content project this clip ended up being used in.
  /// Set null (not cascaded) if that project is deleted, so the clip
  /// itself survives.
  TextColumn get linkedProjectId =>
      text().nullable().references(ContentProjects, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
