import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../daos/assets_dao.dart';
import 'asset_mapper.dart';

class AssetRepositoryImpl implements AssetRepository {
  AssetRepositoryImpl(this._dao);

  final AssetsDao _dao;

  @override
  Stream<List<Asset>> watchActiveAssets() {
    return _dao
        .watchActiveAssets()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Asset?> watchAsset(String id) {
    return _dao.watchAsset(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Asset>> createAsset(Asset asset) async {
    try {
      await _dao.insertAsset(asset.toCompanion());
      return Result.ok(asset);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save asset: $e'));
    }
  }

  @override
  Future<Result<Asset>> updateAsset(Asset asset) async {
    try {
      final bool updated = await _dao.updateAsset(asset.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Asset no longer exists.'));
      }
      return Result.ok(asset);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update asset: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAsset(String id) async {
    try {
      await _dao.deleteAsset(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete asset: $e'));
    }
  }
}
