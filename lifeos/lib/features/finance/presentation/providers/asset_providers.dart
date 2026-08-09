import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/assets_dao.dart';
import '../../data/repositories/asset_repository_impl.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../domain/usecases/create_asset.dart';
import '../../domain/usecases/delete_asset.dart';
import '../../domain/usecases/update_asset.dart';

final Provider<AssetsDao> assetsDaoProvider = Provider<AssetsDao>((ref) {
  return AssetsDao(ref.watch(appDatabaseProvider));
});

final Provider<AssetRepository> assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepositoryImpl(ref.watch(assetsDaoProvider));
});

final Provider<CreateAsset> createAssetUseCaseProvider = Provider(
  (ref) => CreateAsset(ref.watch(assetRepositoryProvider)),
);
final Provider<UpdateAsset> updateAssetUseCaseProvider = Provider(
  (ref) => UpdateAsset(ref.watch(assetRepositoryProvider)),
);
final Provider<DeleteAsset> deleteAssetUseCaseProvider = Provider(
  (ref) => DeleteAsset(ref.watch(assetRepositoryProvider)),
);

final StreamProvider<List<Asset>> activeAssetsProvider = StreamProvider<List<Asset>>((ref) {
  return ref.watch(assetRepositoryProvider).watchActiveAssets();
});

final StreamProviderFamily<Asset?, String> assetByIdProvider =
    StreamProvider.family<Asset?, String>((ref, id) {
  return ref.watch(assetRepositoryProvider).watchAsset(id);
});
