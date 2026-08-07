import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/finance/data/daos/accounts_dao.dart';
import '../../features/finance/data/tables/accounts_table.dart';

part 'app_database.g.dart';

/// The single, app-wide SQLite database. Every module's tables live here
/// so the database can enforce cross-module foreign keys (e.g. a habit
/// linking to a Finance account, or a task linking to a Creator Studio
/// project) as those modules are built out.
///
/// Bump [schemaVersion] and add a migration step whenever a table changes
/// shape — never edit an already-released table in place.
@DriftDatabase(
  tables: [Accounts],
  daos: [AccountsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory constructor so features can be unit tested without
  /// touching the filesystem.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Add `if (from < N) { ... }` migration steps here as the schema
          // grows across future modules.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'lifeos.sqlite'));
    return NativeDatabase.createInBackground(file, setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON;');
    });
  });
}
