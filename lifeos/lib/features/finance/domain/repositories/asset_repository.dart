import '../../../../core/utils/result.dart';
import '../entities/asset.dart';

abstract interface class AssetRepository {
  Stream<List<Asset>> watchActiveAssets();
  Stream<Asset?> watchAsset(String id);

  Future<Result<Asset>> createAsset(Asset asset);
  Future<Result<Asset>> updateAsset(Asset asset);
  Future<Result<void>> deleteAsset(String id);
}
