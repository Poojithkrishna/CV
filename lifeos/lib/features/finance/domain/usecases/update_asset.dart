import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';
import 'create_asset.dart';

class UpdateAsset {
  UpdateAsset(this._repository);

  final AssetRepository _repository;

  Future<Result<Asset>> call(Asset asset) async {
    final Failure? error = CreateAsset.validate(asset);
    if (error != null) return Result.err(error);
    return _repository.updateAsset(asset.copyWith(updatedAt: DateTime.now()));
  }
}
