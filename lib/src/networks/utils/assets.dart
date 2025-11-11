import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/substrate.dart';

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
      throw DartSubstratePluginException("Missing transfer asset.");
    }
    if (method != AssetsCallPalletMethod.transferAll && amount == null) {
      throw DartSubstratePluginException(
          "An amount is required unless using ${AssetsCallPalletMethod.transferAll.method}.");
    }
    return switch (method) {
      AssetsCallPalletMethod.transfer =>
        AssetsCallPalletTransfer(target: target, amount: amount!, id: assetId),
      AssetsCallPalletMethod.transferKeepAlive =>
        AssetsCallPalletTransferKeepAlive(
            target: target, amount: amount!, id: assetId),
      AssetsCallPalletMethod.transferAll => AssetsCallPalletTransferAll(
          dest: target, keepAlive: keepAlive ?? true, id: assetId),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalForeignAssetPalletTransfer(
      {required BaseSubstrateAddress target,
      required MetadataWithExtrinsic metadata,
      required BaseSubstrateNetworkAsset? asset,
      BigInt? amount,
      required ForeignAssetsCallPalletMethod method,
      bool? keepAlive}) {
    final location = asset?.location?.location;
    if (method != ForeignAssetsCallPalletMethod.transferAll && amount == null) {
      throw DartSubstratePluginException(
          "An amount is required unless using ${ForeignAssetsCallPalletMethod.transferAll.method}.");
    }
    if (location == null) {
      throw DartSubstratePluginException(
          "Invalid foreign asset. missing asset location.");
    }
    if (location.isZeroParents()) {
      throw DartSubstratePluginException("Invalid asset location.");
    }
    return switch (method) {
      ForeignAssetsCallPalletMethod.transfer => ForeignAssetsCallPalletTransfer(
          target: target, amount: amount!, id: location),
      ForeignAssetsCallPalletMethod.transferKeepAlive =>
        ForeignAssetsCallPalletTransferKeepAlive(
            target: target, amount: amount!, id: location),
      ForeignAssetsCallPalletMethod.transferAll =>
        ForeignAssetsCallPalletTransferAll(
            dest: target, keepAlive: keepAlive ?? true, id: location),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalFungiblesPalletTransfer(
      {required BaseSubstrateAddress target,
      required MetadataWithExtrinsic metadata,
      required BaseSubstrateNetworkAsset? asset,
      BigInt? amount,
      required FungiblesCallPalletMethod method,
      bool? keepAlive}) {
    if (method != FungiblesCallPalletMethod.transferAll && amount == null) {
      throw DartSubstratePluginException(
          "An amount is required unless using ${FungiblesCallPalletMethod.transferAll.method}.");
    }
    final location = asset?.location?.location;
    if (location == null) {
      throw DartSubstratePluginException(
          "Invalid foreign asset. missing asset location.");
    }
    return switch (method) {
      FungiblesCallPalletMethod.transfer => FungiblesCallPalletTransfer(
          target: target, amount: amount!, id: location),
      FungiblesCallPalletMethod.transferKeepAlive =>
        FungiblesCallPalletTransferKeepAlive(
            target: target, amount: amount!, id: location),
      FungiblesCallPalletMethod.transferAll => FungiblesCallPalletTransferAll(
          dest: target, keepAlive: keepAlive ?? true, id: location),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalTokensPalletTransfer(
      {required BaseSubstrateAddress target,
      required MetadataWithExtrinsic metadata,
      required BaseSubstrateNetworkAsset? asset,
      required TokensCallPalletMethod method,
      bool? keepAlive,
      BigInt? amount}) {
    final assetId = asset?.identifierAs();
    if (assetId == null) {
      throw DartSubstratePluginException("Missing transfer asset.");
    }
    if (method != TokensCallPalletMethod.transferAll && amount == null) {
      throw DartSubstratePluginException(
          "An amount is required unless using ${TokensCallPalletMethod.transferAll.method}.");
    }
    return switch (method) {
      TokensCallPalletMethod.transfer => TokensCallPalletTransfer(
          dest: target, amount: amount!, currencyId: assetId),
      TokensCallPalletMethod.transferKeepAlive =>
        TokensCallPalletTransferKeepAlive(
            dest: target, amount: amount!, currencyId: assetId),
      TokensCallPalletMethod.transferAll => TokensCallPalletTransferAll(
          dest: target, keepAlive: keepAlive ?? true, currencyId: assetId),
    };
  }

  static SubstrateLocalTransferCallPallet createLocalAssetManagerPalletTransfer(
      {required BaseSubstrateAddress destination,
      BigInt? amount,
      required MetadataWithExtrinsic metadata,
      required AssetManagerCallPalletMethod method,
      required BaseSubstrateNetworkAsset? asset}) {
    if (amount == null) {
      throw DartSubstratePluginException(
          "An amount is required for transfer asset.");
    }
    if (method == AssetManagerCallPalletMethod.transfer &&
        asset?.identifier == null) {
      throw DartSubstratePluginException("Missing asset identifier.");
    }
    if (method == AssetManagerCallPalletMethod.transfernativeCurrency &&
        asset != null &&
        !asset.type.isNative) {
      throw DartSubstratePluginException(
          "Mismatch between transfer method and asset type.");
    }
    return switch (method) {
      AssetManagerCallPalletMethod.transfernativeCurrency =>
        AssetManagerCallPalletTransferNativeCurrency(
            dest: destination, amount: amount),
      AssetManagerCallPalletMethod.transfer => AssetManagerCallPalletTransfer(
          dest: destination, currencyId: asset!.identifierAs(), amount: amount)
    };
  }

  static SubstrateLocalTransferCallPallet createLocalCurrenciesPalletTransfer(
      {required BaseSubstrateAddress destination,
      required BigInt? amount,
      required MetadataWithExtrinsic metadata,
      required BaseSubstrateNetworkAsset? asset,
      required CurrenciesCallPalletMethod method}) {
    if (amount == null) {
      throw DartSubstratePluginException(
          "An amount is required for transfer asset.");
    }
    if (method == CurrenciesCallPalletMethod.transfer &&
        asset?.identifier == null) {
      throw DartSubstratePluginException("Missing asset identifier.");
    }
    if (method == CurrenciesCallPalletMethod.transfernativeCurrency &&
        asset != null &&
        !asset.type.isNative) {
      throw DartSubstratePluginException(
          "Mismatch between transfer method and asset type.");
    }
    CurrenciesCallPallet transfer = switch (method) {
      CurrenciesCallPalletMethod.transfernativeCurrency =>
        CurrenciesCallPalletTransferNativeCurrency(
            dest: destination, amount: amount),
      CurrenciesCallPalletMethod.transfer => CurrenciesCallPalletTransfer(
          dest: destination, currencyId: asset!.identifierAs(), amount: amount),
    };
    return transfer;
  }

  static List<T> _getMethods<T extends SubstrateCallPalletTransferMethod>(
      MetadataWithExtrinsic metadata, SubtrateMetadataPallet pallet) {
    final methods = metadata.api.metadata.getCallMethodNames(pallet.name);
    switch (pallet) {
      case SubtrateMetadataPallet.balances:
        return BalancesCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubtrateMetadataPallet.assetManager:
        return AssetManagerCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubtrateMetadataPallet.currencies:
        return CurrenciesCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubtrateMetadataPallet.foreignAssets:
        return ForeignAssetsCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubtrateMetadataPallet.fungibles:
        return FungiblesCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      case SubtrateMetadataPallet.assets:
        return AssetsCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();

      case SubtrateMetadataPallet.tokens:
        return TokensCallPalletMethod.values
            .where((e) => methods.contains(e.method))
            .cast<T>()
            .toList();
      default:
        return [];
    }
  }

  static SubstrateLocalTransferCallPallet createLocalBalancesPalletTransfer(
      {required BaseSubstrateAddress destination,
      required MetadataWithExtrinsic metadata,
      BigInt? amount,
      required BalancesCallPalletMethod method,
      bool? keepAlive}) {
    if (method != BalancesCallPalletMethod.transferAll && amount == null) {
      throw DartSubstratePluginException(
          "An amount is required unless using ${BalancesCallPalletMethod.transferAll.method}.");
    }
    if (method == BalancesCallPalletMethod.transferAll && amount != null) {
      throw DartSubstratePluginException(
          "${BalancesCallPalletMethod.transferAll.method} does not accept an amount. amount must be null.");
    }
    return switch (method) {
      BalancesCallPalletMethod.transferAllowDeath =>
        BalancesCallPalletTransferAllowDeath(
            dest: destination, amount: amount!),
      BalancesCallPalletMethod.transferKeepAlive =>
        BalancesCallPalletTransferKeepAlive(dest: destination, amount: amount!),
      BalancesCallPalletMethod.transferAll => BalancesCallPalletTransferAll(
          dest: destination, keepAlive: keepAlive ?? true),
    };
  }

  static SubtrateMetadataPallet findExcutionPallet(
      {BaseSubstrateNetworkAsset? asset,
      required MetadataWithExtrinsic metadata}) {
    if (asset != null) return asset.excutionPallet;
    final currencies = _getMethods(metadata, SubtrateMetadataPallet.currencies);
    final assetManager =
        _getMethods(metadata, SubtrateMetadataPallet.assetManager);
    final balances = _getMethods(metadata, SubtrateMetadataPallet.balances);
    SubtrateMetadataPallet? excutionPallet;
    if (balances.isNotEmpty) {
      excutionPallet = SubtrateMetadataPallet.balances;
    } else if (currencies
        .contains(CurrenciesCallPalletMethod.transfernativeCurrency)) {
      excutionPallet = SubtrateMetadataPallet.currencies;
    } else if (assetManager
        .contains(AssetManagerCallPalletMethod.transfernativeCurrency)) {
      excutionPallet = SubtrateMetadataPallet.assetManager;
    }
    if (excutionPallet == null) {
      throw DartSubstratePluginException(
          "Unable to find asset transfer pallet.");
    }
    return excutionPallet;
  }

  static List<SubstrateCallPalletTransferMethod> transferMethods(
      {BaseSubstrateNetworkAsset? asset,
      required MetadataWithExtrinsic metadata}) {
    final excution = findExcutionPallet(metadata: metadata, asset: asset);
    final bool isNativeAssets = asset == null || asset.type.isNative;

    final methods = _getMethods(metadata, excution);
    switch (excution) {
      case SubtrateMetadataPallet.balances:
        final currencies =
            _getMethods(metadata, SubtrateMetadataPallet.currencies);
        final assetManager =
            _getMethods(metadata, SubtrateMetadataPallet.assetManager);
        return [
          ...methods,
          if (currencies
              .contains(CurrenciesCallPalletMethod.transfernativeCurrency))
            CurrenciesCallPalletMethod.transfernativeCurrency,
          if (assetManager
              .contains(AssetManagerCallPalletMethod.transfernativeCurrency))
            AssetManagerCallPalletMethod.transfernativeCurrency
        ];
      case SubtrateMetadataPallet.currencies:
        if (isNativeAssets) {
          if (methods
              .contains(CurrenciesCallPalletMethod.transfernativeCurrency)) {
            return [CurrenciesCallPalletMethod.transfernativeCurrency];
          }
        } else if (methods.contains(CurrenciesCallPalletMethod.transfer)) {
          return [CurrenciesCallPalletMethod.transfer];
        }
        return [];
      case SubtrateMetadataPallet.assetManager:
        if (isNativeAssets) {
          if (methods
              .contains(AssetManagerCallPalletMethod.transfernativeCurrency)) {
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

  static SubstrateTransferEncodedParams createLocalTransfer(
      {required SubstrateLocalTransferAssetParams params,
      required MetadataWithExtrinsic metadata}) {
    SubtrateMetadataPallet source =
        findExcutionPallet(metadata: metadata, asset: params.asset);
    final methods = transferMethods(metadata: metadata, asset: params.asset);
    final keepAlive = params.keepAlive;
    if (methods.isEmpty) {
      throw DartSubstratePluginException(
          "No transfer method available in ${source.name} pallet.");
    }
    String? method = params.method;

    if (method == null) {
      if (params.amount == null) {
        method = BalancesCallPalletMethod.transferAll.method;
      }
      switch (source) {
        case SubtrateMetadataPallet.fungibles:
        case SubtrateMetadataPallet.assets:
        case SubtrateMetadataPallet.foreignAssets:
        case SubtrateMetadataPallet.tokens:
          if (keepAlive == null) {
            method = methods
                .firstWhere(
                    (e) =>
                        e.method ==
                        BalancesCallPalletMethod.transferKeepAlive.method,
                    orElse: () => methods.first)
                .method;
          } else {
            if (keepAlive) {
              method = AssetsCallPalletMethod.transferKeepAlive.method;
            } else {
              method = AssetsCallPalletMethod.transfer.method;
            }
          }

          break;
        case SubtrateMetadataPallet.balances:
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
        orElse: () => throw DartSubstratePluginException(
            "$method not supported by ${source.name} pallet."));
    if (source == SubtrateMetadataPallet.balances &&
        transferMethod.method ==
            CurrenciesCallPalletMethod.transfernativeCurrency.method) {
      if (metadata.api.palletExists(SubtrateMetadataPallet.currencies.name)) {
        source = SubtrateMetadataPallet.currencies;
      } else if (metadata.api
          .palletExists(SubtrateMetadataPallet.assetManager.name)) {
        source = SubtrateMetadataPallet.assetManager;
      }
    }

    if (!transferMethod.isTransferAll &&
        keepAlive != null &&
        keepAlive != transferMethod.keepAlive) {
      throw DartSubstratePluginException(
          "keepAlive parameter does not match the selected transfer method.");
    }
    if (!transferMethod.isTransferAll && params.amount == null) {
      throw DartSubstratePluginException(
          "An amount is required unless using ${BalancesCallPalletMethod.transferAll.method}.");
    }
    if (transferMethod.isTransferAll &&
        params.method == null &&
        params.amount == null) {
      throw DartSubstratePluginException(
          "No amount specified — please use ${BalancesCallPalletMethod.transferAll.method} method explicitly.");
    }

    final SubstrateLocalTransferCallPallet transfer = switch (source) {
      SubtrateMetadataPallet.balances => createLocalBalancesPalletTransfer(
          destination: params.destinationAddress,
          metadata: metadata,
          method: transferMethod as BalancesCallPalletMethod,
          amount: params.amount,
          keepAlive: params.keepAlive),
      SubtrateMetadataPallet.tokens => createLocalTokensPalletTransfer(
          target: params.destinationAddress,
          metadata: metadata,
          method: transferMethod as TokensCallPalletMethod,
          amount: params.amount,
          keepAlive: params.keepAlive,
          asset: params.asset),
      SubtrateMetadataPallet.currencies => createLocalCurrenciesPalletTransfer(
          destination: params.destinationAddress,
          metadata: metadata,
          amount: params.amount,
          method: transferMethod as CurrenciesCallPalletMethod,
          asset: params.asset),
      SubtrateMetadataPallet.assetManager =>
        createLocalAssetManagerPalletTransfer(
            destination: params.destinationAddress,
            metadata: metadata,
            amount: params.amount,
            method: transferMethod as AssetManagerCallPalletMethod,
            asset: params.asset),
      SubtrateMetadataPallet.foreignAssets =>
        createLocalForeignAssetPalletTransfer(
            target: params.destinationAddress,
            metadata: metadata,
            method: transferMethod as ForeignAssetsCallPalletMethod,
            amount: params.amount,
            keepAlive: params.keepAlive,
            asset: params.asset),
      SubtrateMetadataPallet.fungibles => createLocalFungiblesPalletTransfer(
          target: params.destinationAddress,
          metadata: metadata,
          method: transferMethod as FungiblesCallPalletMethod,
          amount: params.amount,
          keepAlive: params.keepAlive,
          asset: params.asset),
      SubtrateMetadataPallet.assets => createLocalAssetPalletTransfer(
          target: params.destinationAddress,
          metadata: metadata,
          method: transferMethod as AssetsCallPalletMethod,
          amount: params.amount,
          keepAlive: params.keepAlive,
          assetId: params.asset?.identifierAs<BigInt>()),
      _ => throw DartSubstratePluginException(
          "Unable to find asset transfer pallet.")
    };
    return SubstrateTransferEncodedParams(
        transfer: transfer,
        pallet: transfer.pallet.name,
        method: transfer.type.method,
        bytes: transfer.encodeCall(extrinsic: metadata));
  }
}
