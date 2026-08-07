import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/card_emis_table.dart';

part 'card_emis_dao.g.dart';

@DriftAccessor(tables: [CardEmis])
class CardEmisDao extends DatabaseAccessor<AppDatabase> with _$CardEmisDaoMixin {
  CardEmisDao(super.db);

  Stream<List<CardEmiRow>> watchEmisForCard(String cardId) {
    return (select(cardEmis)
          ..where((tbl) => tbl.cardId.equals(cardId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startDate)]))
        .watch();
  }

  Future<CardEmiRow?> getEmi(String id) {
    return (select(cardEmis)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertEmi(CardEmisCompanion entry) {
    return into(cardEmis).insert(entry);
  }

  Future<bool> updateEmi(CardEmisCompanion entry) {
    return update(cardEmis).replace(entry);
  }

  Future<int> deleteEmi(String id) {
    return (delete(cardEmis)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Marks one more installment paid, clamped so it never exceeds the
  /// EMI's tenure.
  Future<void> markInstallmentPaid(String id) async {
    final CardEmiRow? emi = await getEmi(id);
    if (emi == null || emi.monthsPaid >= emi.tenureMonths) return;
    await (update(cardEmis)..where((tbl) => tbl.id.equals(id))).write(
      CardEmisCompanion(
        monthsPaid: Value(emi.monthsPaid + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
