import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/cardio_sessions_table.dart';

part 'cardio_sessions_dao.g.dart';

@DriftAccessor(tables: [CardioSessions])
class CardioSessionsDao extends DatabaseAccessor<AppDatabase> with _$CardioSessionsDaoMixin {
  CardioSessionsDao(super.db);

  Stream<List<CardioSessionRow>> watchAllSessions() {
    return (select(cardioSessions)..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])).watch();
  }

  Stream<CardioSessionRow?> watchSession(String id) {
    return (select(cardioSessions)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertSession(CardioSessionsCompanion entry) {
    return into(cardioSessions).insert(entry);
  }

  Future<bool> updateSession(CardioSessionsCompanion entry) {
    return update(cardioSessions).replace(entry);
  }

  Future<int> deleteSession(String id) {
    return (delete(cardioSessions)..where((tbl) => tbl.id.equals(id))).go();
  }
}
