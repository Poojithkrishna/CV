import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/investments_table.dart';

part 'investments_dao.g.dart';

@DriftAccessor(tables: [Investments])
class InvestmentsDao extends DatabaseAccessor<AppDatabase> with _$InvestmentsDaoMixin {
  InvestmentsDao(super.db);

  Stream<List<InvestmentRow>> watchActiveInvestments() {
    return (select(investments)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<InvestmentRow?> watchInvestment(String id) {
    return (select(investments)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertInvestment(InvestmentsCompanion entry) {
    return into(investments).insert(entry);
  }

  Future<bool> updateInvestment(InvestmentsCompanion entry) {
    return update(investments).replace(entry);
  }

  Future<int> deleteInvestment(String id) {
    return (delete(investments)..where((tbl) => tbl.id.equals(id))).go();
  }
}
