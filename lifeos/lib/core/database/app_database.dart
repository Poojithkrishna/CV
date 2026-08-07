import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/finance/data/daos/accounts_dao.dart';
import '../../features/finance/data/daos/categories_dao.dart';
import '../../features/finance/data/daos/transactions_dao.dart';
import '../../features/finance/data/tables/accounts_table.dart';
import '../../features/finance/data/tables/categories_table.dart';
import '../../features/finance/data/tables/transactions_table.dart';
import 'default_categories.dart';

part 'app_database.g.dart';

/// The single, app-wide SQLite database. Every module's tables live here
/// so the database can enforce cross-module foreign keys (e.g. a habit
/// linking to a Finance account, or a task linking to a Creator Studio
/// project) as those modules are built out.
///
/// Bump [schemaVersion] and add a migration step whenever a table changes
/// shape — never edit an already-released table in place.
@DriftDatabase(
  tables: [Accounts, Categories, Transactions],
  daos: [AccountsDao, CategoriesDao, TransactionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory constructor so features can be unit tested without
  /// touching the filesystem.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultCategories();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(categories);
            await m.createTable(transactions);
            await _seedDefaultCategories();
          }
        },
      );

  Future<void> _seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(categories, buildDefaultCategorySeed(DateTime.now()));
    });
  }
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
