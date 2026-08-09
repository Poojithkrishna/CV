import 'package:drift/drift.dart';

@DataClassName('ClipRow')
class Clips extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  TextColumn get game => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();

  /// Optional — which content project this clip ended up being used in.
  /// Set null (not cascaded) if that project is deleted, so the clip
  /// itself survives. Uses `.customConstraint()` rather than
  /// `.references()` — see milestones_table.dart in the goals feature
  /// for why (the latter's generated constraint was silently dropped by
  /// drift_dev in this schema).
  TextColumn get linkedProjectId =>
      text().nullable().customConstraint('REFERENCES content_projects (id) ON DELETE SET NULL')();

  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
