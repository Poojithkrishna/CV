import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/journal_entries_table.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  Stream<List<JournalEntryRow>> watchAllEntries() {
    return (select(journalEntries)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.date),
            (tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .watch();
  }

  Stream<JournalEntryRow?> watchEntry(String id) {
    return (select(journalEntries)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertEntry(JournalEntriesCompanion entry) {
    return into(journalEntries).insert(entry);
  }

  Future<bool> updateEntry(JournalEntriesCompanion entry) {
    return update(journalEntries).replace(entry);
  }

  Future<int> deleteEntry(String id) {
    return (delete(journalEntries)..where((tbl) => tbl.id.equals(id))).go();
  }
}
