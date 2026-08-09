import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies a picked image into its own subdirectory under the app's
/// documents directory so it survives independently of wherever the
/// camera/gallery originally stored it, and returns the new path to
/// save on the owning row (e.g. `ProgressPhoto.filePath`,
/// `ContentProject.thumbnailPath`).
Future<String> saveImageFile(String sourcePath, String id, {required String subdirectory}) async {
  final Directory documentsDir = await getApplicationDocumentsDirectory();
  final Directory targetDir = Directory(p.join(documentsDir.path, subdirectory));
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }
  final String extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
  final String destinationPath = p.join(targetDir.path, '$id$extension');
  await File(sourcePath).copy(destinationPath);
  return destinationPath;
}

/// Deletes a previously-saved image file, ignoring a missing file (the
/// user may have already cleared app storage manually).
Future<void> deleteImageFile(String filePath) async {
  final File file = File(filePath);
  if (await file.exists()) {
    await file.delete();
  }
}
