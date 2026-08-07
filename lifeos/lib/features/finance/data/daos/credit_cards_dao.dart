import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/credit_cards_table.dart';

part 'credit_cards_dao.g.dart';

@DriftAccessor(tables: [CreditCards])
class CreditCardsDao extends DatabaseAccessor<AppDatabase> with _$CreditCardsDaoMixin {
  CreditCardsDao(super.db);

  Stream<List<CreditCardRow>> watchActiveCards() {
    return (select(creditCards)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Stream<CreditCardRow?> watchCard(String id) {
    return (select(creditCards)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<CreditCardRow?> getCard(String id) {
    return (select(creditCards)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertCard(CreditCardsCompanion entry) {
    return into(creditCards).insert(entry);
  }

  Future<bool> updateCard(CreditCardsCompanion entry) {
    return update(creditCards).replace(entry);
  }

  Future<int> deleteCard(String id) {
    return (delete(creditCards)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// `usage = usage + delta` — positive to record a new charge, negative
  /// to record a payment towards the balance.
  Future<void> adjustUsage(String cardId, double delta) async {
    await (update(creditCards)..where((tbl) => tbl.id.equals(cardId))).write(
      CreditCardsCompanion.custom(
        currentUsage: creditCards.currentUsage + Variable(delta),
        updatedAt: Variable(DateTime.now()),
      ),
    );
  }
}
