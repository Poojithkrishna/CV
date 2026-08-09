import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a picked image into the app's own documents directory (under
/// `progress_photos/`) so it survives independently of wherever the
/// camera/gallery originally stored it, and returns the new path to save
/// on the `ProgressPhoto` row.
Future<String> savePhotoFile(String sourcePath, String id) async {
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final Directory photosDir = Directory(p.join(documentsDir.path, 'progress_photos'));
  if (!await photosDir.exists()) {
    await photosDir.create(recursive: true);
  }
  final String extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
  final String destinationPath = p.join(photosDir.path, '$id$extension');
  await File(sourcePath).copy(destinationPath);
  return destinationPath;
}

/// Deletes a previously-saved photo file, ignoring a missing file (the
/// user may have already cleared app storage manually).
Future<void> deletePhotoFile(String filePath) async {
  final File file = File(filePath);
  if (await file.exists()) {
    await file.delete();
  }
}
