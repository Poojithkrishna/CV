import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// First 16 bytes of every SQLite3 database file — the standard way to
/// tell "this is really a SQLite file" from "this is garbage" before
/// ever letting it near the app's real database.
const List<int> _sqliteHeaderMagic = [
  0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
  0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
];

final DateFormat _exportTimestampFormat = DateFormat('yyyyMMdd-HHmmss');

/// Backup export/restore, built around raw SQLite file operations
/// rather than a hand-rolled JSON schema for every table — a straight
/// file copy is a perfect, full-fidelity backup by construction, and a
/// restored file re-opens through the app's normal migration path
/// (Drift tracks its own schema version inside the file itself), so an
/// older backup restored into a newer app version just upgrades in
/// place like any other launch would.
class BackupService {
  Future<String> resolveDatabaseFilePath() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    return p.join(dbFolder.path, 'lifeos.sqlite');
  }

  Future<String> resolveDefaultExportPath({DateTime? now}) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String timestamp = _exportTimestampFormat.format(now ?? DateTime.now());
    return p.join(tempDir.path, 'lifeos-backup-$timestamp.sqlite');
  }

  /// Writes a consistent, compacted snapshot of [database] to
  /// [exportPath] via SQLite's own `VACUUM INTO` — safe to run even
  /// while [database] is open and in active use, unlike copying the
  /// raw file out from under a live connection.
  Future<void> exportTo(AppDatabase database, String exportPath) async {
    await database.customStatement("VACUUM INTO '$exportPath'");
  }

  /// Whether [file]'s first 16 bytes match the SQLite3 file header —
  /// the one check standing between a real backup and silently
  /// clobbering everything in Demon Origin with an arbitrary file.
  Future<bool> isValidSqliteFile(File file) async {
    if (!await file.exists()) return false;
    final RandomAccessFile handle = await file.open();
    try {
      if (await handle.length() < _sqliteHeaderMagic.length) return false;
      final List<int> header = await handle.read(_sqliteHeaderMagic.length);
      for (int i = 0; i < _sqliteHeaderMagic.length; i++) {
        if (header[i] != _sqliteHeaderMagic[i]) return false;
      }
      return true;
    } finally {
      await handle.close();
    }
  }

  /// Overwrites the live database file at [databaseFilePath] with
  /// [backupFile]. The caller must have already closed the live
  /// `AppDatabase` connection — this only touches the file itself.
  Future<void> installBackupFile(File backupFile, String databaseFilePath) async {
    await backupFile.copy(databaseFilePath);
  }
}
