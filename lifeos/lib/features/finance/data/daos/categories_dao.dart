import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<CategoryRow>> watchActiveCategories({String? type}) {
    final query = select(categories)
      ..where((tbl) => tbl.isArchived.equals(false));
    if (type != null) {
      query.where((tbl) => tbl.type.equals(type));
    }
    query.orderBy([
      (tbl) => OrderingTerm.asc(tbl.sortOrder),
      (tbl) => OrderingTerm.asc(tbl.name),
    ]);
    return query.watch();
  }

  Stream<CategoryRow?> watchCategory(String id) {
    return (select(categories)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<CategoryRow?> getCategory(String id) {
    return (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }

  Future<bool> updateCategory(CategoriesCompanion entry) {
    return update(categories).replace(entry);
  }

  Future<int> deleteCategory(String id) {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
