import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/recurring_payments_table.dart';

part 'recurring_payments_dao.g.dart';

@DriftAccessor(tables: [RecurringPayments])
class RecurringPaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringPaymentsDaoMixin {
  RecurringPaymentsDao(super.db);

  Stream<List<RecurringPaymentRow>> watchActivePayments() {
    return (select(recurringPayments)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nextDueDate)]))
        .watch();
  }

  Stream<RecurringPaymentRow?> watchPayment(String id) {
    return (select(recurringPayments)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<RecurringPaymentRow?> getPayment(String id) {
    return (select(recurringPayments)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertPayment(RecurringPaymentsCompanion entry) {
    return into(recurringPayments).insert(entry);
  }

  Future<bool> updatePayment(RecurringPaymentsCompanion entry) {
    return update(recurringPayments).replace(entry);
  }

  Future<int> deletePayment(String id) {
    return (delete(recurringPayments)..where((tbl) => tbl.id.equals(id))).go();
  }
}
