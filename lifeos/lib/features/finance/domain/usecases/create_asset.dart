import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class CreateAsset {
  CreateAsset(this._repository);

  final AssetRepository _repository;

  Future<Result<Asset>> call(Asset asset) async {
    final Failure? error = validate(asset);
    if (error != null) return Result.err(error);
    return _repository.createAsset(asset);
  }

  static Failure? validate(Asset asset) {
    if (asset.name.trim().isEmpty) {
      return const ValidationFailure('Asset name is required.');
    }
    if (asset.currentValue < 0) {
      return const ValidationFailure('Value cannot be negative.');
    }
    if (asset.purchasePrice != null && asset.purchasePrice! < 0) {
      return const ValidationFailure('Purchase price cannot be negative.');
    }
    return null;
  }
}
