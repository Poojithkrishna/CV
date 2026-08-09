import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/backup/backup_service.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/account_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/account.dart';
import 'package:lifeos/features/finance/domain/entities/account_type.dart';
import 'package:path/path.dart' as p;

Account _buildAccount(String id) {
  final DateTime now = DateTime(2026, 1, 1);
  return Account(
    id: id,
    name: 'Account $id',
    type: AccountType.bank,
    currentBalance: 500,
    openingBalance: 500,
    colorValue: 0xFF22C55E,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late Directory tempDir;
  late BackupService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lifeos_backup_test_');
    service = BackupService();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('isValidSqliteFile', () {
    test('is true for a real SQLite database file', () async {
      final AppDatabase database = AppDatabase.forTesting(NativeDatabase.memory());
      final String exportPath = p.join(tempDir.path, 'export.sqlite');
      await service.exportTo(database, exportPath);
      await database.close();

      expect(await service.isValidSqliteFile(File(exportPath)), isTrue);
    });

    test('is false for a file with unrelated content', () async {
      final File file = File(p.join(tempDir.path, 'not-a-backup.txt'));
      await file.writeAsString('just some plain text, not a database');

      expect(await service.isValidSqliteFile(file), isFalse);
    });

    test('is false for a file shorter than the SQLite header', () async {
      final File file = File(p.join(tempDir.path, 'tiny.bin'));
      await file.writeAsBytes([1, 2, 3]);

      expect(await service.isValidSqliteFile(file), isFalse);
    });

    test('is false for a file that does not exist', () async {
      final File file = File(p.join(tempDir.path, 'missing.sqlite'));
      expect(await service.isValidSqliteFile(file), isFalse);
    });
  });

  group('exportTo', () {
    test('produces a file that reopens with the same data', () async {
      final AppDatabase source = AppDatabase.forTesting(NativeDatabase.memory());
      await source.accountsDao.insertAccount(_buildAccount('a1').toCompanion());

      final String exportPath = p.join(tempDir.path, 'export.sqlite');
      await service.exportTo(source, exportPath);
      await source.close();

      final AppDatabase reopened = AppDatabase.forTesting(NativeDatabase(File(exportPath)));
      final rows = await reopened.accountsDao.watchActiveAccounts().first;
      await reopened.close();

      expect(rows, hasLength(1));
      expect(rows.single.id, 'a1');
      expect(rows.single.currentBalance, 500);
    });
  });

  group('installBackupFile', () {
    test('overwrites the target path with the backup file\'s contents', () async {
      final File backup = File(p.join(tempDir.path, 'backup.sqlite'));
      await backup.writeAsString('backup contents');
      final String targetPath = p.join(tempDir.path, 'live.sqlite');
      await File(targetPath).writeAsString('stale live contents');

      await service.installBackupFile(backup, targetPath);

      expect(await File(targetPath).readAsString(), 'backup contents');
    });
  });
}
