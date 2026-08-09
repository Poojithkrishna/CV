import 'package:drift/drift.dart';

@DataClassName('ProgressPhotoRow')
class ProgressPhotos extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();

  /// Absolute path under the app's own documents directory — see
  /// `saveImageFile`/`deleteImageFile` in `core/utils/photo_storage.dart`.
  TextColumn get filePath => text()();

  /// Stored as [PhotoCategory.name].
  TextColumn get category => text()();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
