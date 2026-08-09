import '../../../../core/utils/result.dart';
import '../repositories/asset_repository.dart';

class DeleteAsset {
  DeleteAsset(this._repository);

  final AssetRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteAsset(id);
}
