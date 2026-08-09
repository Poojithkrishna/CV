import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/assets_table.dart';

part 'assets_dao.g.dart';

@DriftAccessor(tables: [Assets])
class AssetsDao extends DatabaseAccessor<AppDatabase> with _$AssetsDaoMixin {
  AssetsDao(super.db);

  Stream<List<AssetRow>> watchActiveAssets() {
    return (select(assets)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<AssetRow?> watchAsset(String id) {
    return (select(assets)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertAsset(AssetsCompanion entry) {
    return into(assets).insert(entry);
  }

  Future<bool> updateAsset(AssetsCompanion entry) {
    return update(assets).replace(entry);
  }

  Future<int> deleteAsset(String id) {
    return (delete(assets)..where((tbl) => tbl.id.equals(id))).go();
  }
}
