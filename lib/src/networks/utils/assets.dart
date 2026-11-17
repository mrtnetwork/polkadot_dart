import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/call/call.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/networks/core/assets/assets.dart';
import 'package:polkadot_dart/src/networks/types/types/transaction.dart';

/// Internal helper for building local asset transfer calls; do not use directly.
abstract mixin class SubstrateNetworkControllerLocalAssetTransferBuilder {
  static SubstrateLocalTransferCallPallet createLocalAssetPalletTransfer({
    required BaseSubstrateAddress target,
    required MetadataWithExtrinsic metadata,
    BigInt? assetId,
    BigInt? amount,
    required AssetsCallPalletMethod method,
    bool? keepAlive,
  }) {
    if (assetId == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Missing transfer asset: asset id is required.",
        details: {"method": method.method},
      );
    }
    if (method != AssetsCallPalletMethod.transferAll && amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required unless using ${AssetsCallPalletMethod.transferAll.method}.",
      );
    }
    return switch (method) {
      AssetsCallPalletMethod.transfer => AssetsCallPalletTransfer(
        target: target,
        amount: amount!,
        id: assetId,
      ),
      AssetsCallPalletMethod.transferKeepAlive =>
        AssetsCallPalletTransferKeepAlive(
          target: target,
          amount: amount!,
          id: assetId,
        ),
      AssetsCallPalletMethod.transferAll => AssetsCallPalletTransferAll(
        dest: target,
        keepAlive: keepAlive ?? true,
        id: assetId,
      ),
    };
  }

  static SubstrateLocalTransferCallPallet
  createLocalForeignAssetPalletTransfer({
    required BaseSubstrateAddress target,
    required MetadataWithExtrinsic metadata,
    required BaseSubstrateNetworkAsset? asset,
    BigInt? amount,
    required ForeignAssetsCallPalletMethod method,
    bool? keepAlive,
  }) {
    final location = asset?.location?.location;
    if (method != ForeignAssetsCallPalletMethod.transferAll && amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required unless using ${ForeignAssetsCallPalletMethod.transferAll.method}.",
      );
    }
    if (location == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Invalid foreign asset: missing asset location.",
        details: {"asset": asset?.name ?? asset?.symbol},
      );
    }
    if (location.isZeroParents()) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Invalid asset location: foreign asset must not be Here.",
        details: {"asset": asset?.name ?? asset?.symbol},
      );
    }
    return switch (method) {
      ForeignAssetsCallPalletMethod.transfer => ForeignAssetsCallPalletTransfer(
        target: target,
        amount: amount!,
        id: location,
      ),
      ForeignAssetsCallPalletMethod.transferKeepAlive =>
        ForeignAssetsCallPalletTransferKeepAlive(
          target: target,
          amount: amount!,
          id: location,
        ),
      ForeignAssetsCallPalletMethod.transferAll =>
        ForeignAssetsCallPalletTransferAll(
          dest: target,
          keepAlive: keepAlive ?? true,
          id: location,
        ),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalFungiblesPalletTransfer({
    required BaseSubstrateAddress target,
    required MetadataWithExtrinsic metadata,
    required BaseSubstrateNetworkAsset? asset,
    BigInt? amount,
    required FungiblesCallPalletMethod method,
    bool? keepAlive,
  }) {
    if (method != FungiblesCallPalletMethod.transferAll && amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required unless using ${FungiblesCallPalletMethod.transferAll.method}.",
      );
    }
    final location = asset?.location?.location;
    if (location == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Invalid foreign asset: missing asset location.",
        details: {"asset": asset?.name ?? asset?.symbol},
      );
    }
    return switch (method) {
      FungiblesCallPalletMethod.transfer => FungiblesCallPalletTransfer(
        target: target,
        amount: amount!,
        id: location,
      ),
      FungiblesCallPalletMethod.transferKeepAlive =>
        FungiblesCallPalletTransferKeepAlive(
          target: target,
          amount: amount!,
          id: location,
        ),
      FungiblesCallPalletMethod.transferAll => FungiblesCallPalletTransferAll(
        dest: target,
        keepAlive: keepAlive ?? true,
        id: location,
      ),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalTokensPalletTransfer({
    required BaseSubstrateAddress target,
    required MetadataWithExtrinsic metadata,
    required BaseSubstrateNetworkAsset? asset,
    required TokensCallPalletMethod method,
    bool? keepAlive,
    BigInt? amount,
  }) {
    final assetId = asset?.identifierAs();
    if (assetId == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Missing transfer asset: asset id is required.",
        details: {"method": method.method},
      );
    }
    if (method != TokensCallPalletMethod.transferAll && amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required unless using ${TokensCallPalletMethod.transferAll.method}.",
      );
    }
    return switch (method) {
      TokensCallPalletMethod.transfer => TokensCallPalletTransfer(
        dest: target,
        amount: amount!,
        currencyId: assetId,
      ),
      TokensCallPalletMethod.transferKeepAlive =>
        TokensCallPalletTransferKeepAlive(
          dest: target,
          amount: amount!,
          currencyId: assetId,
        ),
      TokensCallPalletMethod.transferAll => TokensCallPalletTransferAll(
        dest: target,
        keepAlive: keepAlive ?? true,
        currencyId: assetId,
      ),
    };
  }

  static SubstrateLocalTransferCallPallet
  createLocalAssetManagerPalletTransfer({
    required BaseSubstrateAddress destination,
    BigInt? amount,
    required MetadataWithExtrinsic metadata,
    required AssetManagerCallPalletMethod method,
    required BaseSubstrateNetworkAsset? asset,
  }) {
    if (amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required for transfer asset.",
      );
    }
    if (method == AssetManagerCallPalletMethod.transfer &&
        asset?.identifier == null) {
      throw BuError(DefaultErrorType.invalidArgument, "Missing asset identifier.");
    }
    if (method == AssetManagerCallPalletMethod.transfernativeCurrency &&
        asset != null &&
        !asset.type.isNative) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Mismatch between transfer method and asset type.",
      );
    }
    return switch (method) {
      AssetManagerCallPalletMethod.transfernativeCurrency =>
        AssetManagerCallPalletTransferNativeCurrency(
          dest: destination,
          amount: amount,
        ),
      AssetManagerCallPalletMethod.transfer => AssetManagerCallPalletTransfer(
        dest: destination,
        currencyId: asset!.identifierAs(),
        amount: amount,
      ),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalCurrenciesPalletTransfer({
    required BaseSubstrateAddress destination,
    required BigInt? amount,
    required MetadataWithExtrinsic metadata,
    required BaseSubstrateNetworkAsset? asset,
    required CurrenciesCallPalletMethod method,
  }) {
    if (amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required for transfer asset.",
      );
    }
    if (method == CurrenciesCallPalletMethod.transfer &&
        asset?.identifier == null) {
      throw BuError(DefaultErrorType.invalidArgument, "Missing asset identifier.");
    }
    if (method == CurrenciesCallPalletMethod.transfernativeCurrency &&
        asset != null &&
        !asset.type.isNative) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "Mismatch between transfer method and asset type.",
      );
    }
    CurrenciesCallPallet transfer = switch (method) {
      CurrenciesCallPalletMethod.transfernativeCurrency =>
        CurrenciesCallPalletTransferNativeCurrency(
          dest: destination,
          amount: amount,
        ),
      CurrenciesCallPalletMethod.transfer => CurrenciesCallPalletTransfer(
        dest: destination,
        currencyId: asset!.identifierAs(),
        amount: amount,
      ),
    };
    return transfer;
  }

  static List<T> _getMethods<T extends SubstrateCallPalletTransferMethod>(
    MetadataWithExtrinsic metadata,
    SubstrateMetadataPallet pallet,
  ) {
    final methods = metadata.api.metadata.getCallMethodNames(pallet.name);
    switch (pallet) {
      case SubstrateMetadataPallet.balances:
        return BalancesCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubstrateMetadataPallet.assetManager:
        return AssetManagerCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubstrateMetadataPallet.currencies:
        return CurrenciesCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubstrateMetadataPallet.foreignAssets:
        return ForeignAssetsCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubstrateMetadataPallet.fungibles:
        return FungiblesCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubstrateMetadataPallet.assets:
        return AssetsCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();

      case SubstrateMetadataPallet.tokens:
        return TokensCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      default:
        return [];
    }
  }

  static SubstrateLocalTransferCallPallet createLocalBalancesPalletTransfer({
    required BaseSubstrateAddress destination,
    required MetadataWithExtrinsic metadata,
    BigInt? amount,
    required BalancesCallPalletMethod method,
    bool? keepAlive,
  }) {
    if (method != BalancesCallPalletMethod.transferAll && amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required unless using ${BalancesCallPalletMethod.transferAll.method}.",
      );
    }
    if (method == BalancesCallPalletMethod.transferAll && amount != null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "${BalancesCallPalletMethod.transferAll.method} does not accept an amount. amount must be null.",
      );
    }
    return switch (method) {
      BalancesCallPalletMethod.transferAllowDeath =>
        BalancesCallPalletTransferAllowDeath(
          dest: destination,
          amount: amount!,
        ),
      BalancesCallPalletMethod.transferKeepAlive =>
        BalancesCallPalletTransferKeepAlive(dest: destination, amount: amount!),
      BalancesCallPalletMethod.transferAll => BalancesCallPalletTransferAll(
        dest: destination,
        keepAlive: keepAlive ?? true,
      ),
    };
  }

  static SubstrateMetadataPallet findExecutionPallet({
    BaseSubstrateNetworkAsset? asset,
    required MetadataWithExtrinsic metadata,
  }) {
    if (asset != null) return asset.executionPallet;
    final currencies = _getMethods(
      metadata,
      SubstrateMetadataPallet.currencies,
    );
    final assetManager = _getMethods(
      metadata,
      SubstrateMetadataPallet.assetManager,
    );
    final balances = _getMethods(metadata, SubstrateMetadataPallet.balances);
    SubstrateMetadataPallet? executionPallet;
    if (balances.isNotEmpty) {
      executionPallet = SubstrateMetadataPallet.balances;
    } else if (currencies.contains(
      CurrenciesCallPalletMethod.transfernativeCurrency,
    )) {
      executionPallet = SubstrateMetadataPallet.currencies;
    } else if (assetManager.contains(
      AssetManagerCallPalletMethod.transfernativeCurrency,
    )) {
      executionPallet = SubstrateMetadataPallet.assetManager;
    }
    if (executionPallet == null) {
      throw BuError(DefaultErrorType.notFound, 
        "Unable to find asset transfer pallet.",
      );
    }
    return executionPallet;
  }

  static List<SubstrateCallPalletTransferMethod> transferMethods({
    BaseSubstrateNetworkAsset? asset,
    required MetadataWithExtrinsic metadata,
  }) {
    final execution = findExecutionPallet(metadata: metadata, asset: asset);
    final bool isNativeAssets = asset == null || asset.type.isNative;

    final methods = _getMethods(metadata, execution);
    switch (execution) {
      case SubstrateMetadataPallet.balances:
        final currencies = _getMethods(
          metadata,
          SubstrateMetadataPallet.currencies,
        );
        final assetManager = _getMethods(
          metadata,
          SubstrateMetadataPallet.assetManager,
        );
        return [
          ...methods,
          if (currencies.contains(
            CurrenciesCallPalletMethod.transfernativeCurrency,
          ))
            CurrenciesCallPalletMethod.transfernativeCurrency,
          if (assetManager.contains(
            AssetManagerCallPalletMethod.transfernativeCurrency,
          ))
            AssetManagerCallPalletMethod.transfernativeCurrency,
        ];
      case SubstrateMetadataPallet.currencies:
        if (isNativeAssets) {
          if (methods.contains(
            CurrenciesCallPalletMethod.transfernativeCurrency,
          )) {
            return [CurrenciesCallPalletMethod.transfernativeCurrency];
          }
        } else if (methods.contains(CurrenciesCallPalletMethod.transfer)) {
          return [CurrenciesCallPalletMethod.transfer];
        }
        return [];
      case SubstrateMetadataPallet.assetManager:
        if (isNativeAssets) {
          if (methods.contains(
            AssetManagerCallPalletMethod.transfernativeCurrency,
          )) {
            return [AssetManagerCallPalletMethod.transfernativeCurrency];
          }
        } else if (methods.contains(AssetManagerCallPalletMethod.transfer)) {
          return [AssetManagerCallPalletMethod.transfer];
        }
        return [];
      default:
        return methods;
    }
  }

  static SubstrateTransferEncodedParams createLocalTransfer({
    required SubstrateLocalTransferAssetParams params,
    required MetadataWithExtrinsic metadata,
  }) {
    SubstrateMetadataPallet source = findExecutionPallet(
      metadata: metadata,
      asset: params.asset,
    );
    final methods = transferMethods(metadata: metadata, asset: params.asset);
    final keepAlive = params.keepAlive;
    if (methods.isEmpty) {
      throw BuError(DefaultErrorType.unsupported, 
        "No transfer method available in ${source.name} pallet.",
      );
    }
    String? method = params.method;

    if (method == null) {
      if (params.amount == null) {
        method = BalancesCallPalletMethod.transferAll.method;
      }
      switch (source) {
        case SubstrateMetadataPallet.fungibles:
        case SubstrateMetadataPallet.assets:
        case SubstrateMetadataPallet.foreignAssets:
        case SubstrateMetadataPallet.tokens:
          if (keepAlive == null) {
            method =
                methods
                    .firstWhere(
                      (e) =>
                          e.method ==
                          BalancesCallPalletMethod.transferKeepAlive.method,
                      orElse: () => methods.first,
                    )
                    .method;
          } else {
            if (keepAlive) {
              method = AssetsCallPalletMethod.transferKeepAlive.method;
            } else {
              method = AssetsCallPalletMethod.transfer.method;
            }
          }

          break;
        case SubstrateMetadataPallet.balances:
          if (keepAlive ?? true) {
            method = BalancesCallPalletMethod.transferKeepAlive.method;
          } else {
            method = BalancesCallPalletMethod.transferAllowDeath.method;
          }
          break;
        default:
          method = methods.first.method;
      }
    }

    SubstrateCallPalletTransferMethod transferMethod = methods.firstWhere(
      (e) => e.method == method,
      orElse:
          () =>
              throw BuError(DefaultErrorType.unsupported, 
                "$method not supported by ${source.name} pallet.",
              ),
    );
    if (source == SubstrateMetadataPallet.balances &&
        transferMethod.method ==
            CurrenciesCallPalletMethod.transfernativeCurrency.method) {
      if (metadata.api.palletExists(SubstrateMetadataPallet.currencies.name)) {
        source = SubstrateMetadataPallet.currencies;
      } else if (metadata.api.palletExists(
        SubstrateMetadataPallet.assetManager.name,
      )) {
        source = SubstrateMetadataPallet.assetManager;
      }
    }

    if (!transferMethod.isTransferAll &&
        keepAlive != null &&
        keepAlive != transferMethod.keepAlive) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "keepAlive parameter does not match the selected transfer method.",
      );
    }
    if (!transferMethod.isTransferAll && params.amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "An amount is required unless using ${BalancesCallPalletMethod.transferAll.method}.",
      );
    }
    if (transferMethod.isTransferAll &&
        params.method == null &&
        params.amount == null) {
      throw BuError(DefaultErrorType.invalidArgument, 
        "No amount specified — please use ${BalancesCallPalletMethod.transferAll.method} method explicitly.",
      );
    }

    final SubstrateLocalTransferCallPallet transfer = switch (source) {
      SubstrateMetadataPallet.balances => createLocalBalancesPalletTransfer(
        destination: params.destinationAddress,
        metadata: metadata,
        method: transferMethod as BalancesCallPalletMethod,
        amount: params.amount,
        keepAlive: params.keepAlive,
      ),
      SubstrateMetadataPallet.tokens => createLocalTokensPalletTransfer(
        target: params.destinationAddress,
        metadata: metadata,
        method: transferMethod as TokensCallPalletMethod,
        amount: params.amount,
        keepAlive: params.keepAlive,
        asset: params.asset,
      ),
      SubstrateMetadataPallet.currencies => createLocalCurrenciesPalletTransfer(
        destination: params.destinationAddress,
        metadata: metadata,
        amount: params.amount,
        method: transferMethod as CurrenciesCallPalletMethod,
        asset: params.asset,
      ),
      SubstrateMetadataPallet.assetManager =>
        createLocalAssetManagerPalletTransfer(
          destination: params.destinationAddress,
          metadata: metadata,
          amount: params.amount,
          method: transferMethod as AssetManagerCallPalletMethod,
          asset: params.asset,
        ),
      SubstrateMetadataPallet.foreignAssets =>
        createLocalForeignAssetPalletTransfer(
          target: params.destinationAddress,
          metadata: metadata,
          method: transferMethod as ForeignAssetsCallPalletMethod,
          amount: params.amount,
          keepAlive: params.keepAlive,
          asset: params.asset,
        ),
      SubstrateMetadataPallet.fungibles => createLocalFungiblesPalletTransfer(
        target: params.destinationAddress,
        metadata: metadata,
        method: transferMethod as FungiblesCallPalletMethod,
        amount: params.amount,
        keepAlive: params.keepAlive,
        asset: params.asset,
      ),
      SubstrateMetadataPallet.assets => createLocalAssetPalletTransfer(
        target: params.destinationAddress,
        metadata: metadata,
        method: transferMethod as AssetsCallPalletMethod,
        amount: params.amount,
        keepAlive: params.keepAlive,
        assetId: params.asset?.identifierAs<BigInt>(),
      ),
      _ =>
        throw BuError(DefaultErrorType.notFound, 
          "Unable to find asset transfer pallet.",
        ),
    };
    return SubstrateTransferEncodedParams(
      transfer: transfer,
      pallet: transfer.pallet.name,
      method: transfer.type.method,
      bytes: transfer.encodeCall(extrinsic: metadata),
    );
  }
}
