import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/asset.dart';
import 'asset_providers.dart';

class AssetFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Asset>> save(Asset asset, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Asset> result = isEditing
        ? await ref.read(updateAssetUseCaseProvider).call(asset)
        : await ref.read(createAssetUseCaseProvider).call(asset);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<AssetFormController, void> assetFormControllerProvider =
    AsyncNotifierProvider.autoDispose<AssetFormController, void>(
  AssetFormController.new,
);
