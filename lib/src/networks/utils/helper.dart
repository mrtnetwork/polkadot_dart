import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/substrate.dart';

/// Internal helper for querying network assets, asset locations, fees, and related info.
/// Methods in this class are mostly for internal use and rely on knowledge of network structures.
abstract mixin class SubstrateNetworkControllerAssetQueryHelper {
  static Future<Map<BigInt, Map<String, dynamic>>>
      getAssetsPalletAssetIdentifierBigInt(MetadataWithProvider provider,
          {List<BigInt>? assetIds}) async {
    if (assetIds != null) {
      List<(BigInt, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.assets.assets<BigInt>(
              api: provider.metadata.api,
              rpc: provider.provider,
              ids: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();

      return {for (final i in assetEntries) i.$1: i.$2!};
    }
    final assetEntries = await SubstrateQuickStorageApi.assets
        .assetEnteries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsBigInt(0): i.response
    };
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getEvmForeignAssetsPalletIdentifierBigInt(
          {required MetadataWithProvider provider,
          required XCMVersion version,
          List<BigInt>? assetIds}) async {
    if (assetIds != null) {
      List<(BigInt, Map<String, dynamic>?)> evmForeignAssets =
          await SubstrateQuickStorageApi.evmForeignAssets.assetsById<BigInt>(
              api: provider.metadata.api,
              rpc: provider.provider,
              ids: assetIds);
      evmForeignAssets = evmForeignAssets.where((e) => e.$2 != null).toList();

      return {
        for (final i in evmForeignAssets)
          i.$1: XCMMultiLocation.fromJson(json: i.$2!, version: version)
              .asVersioned()
      };
    }
    final assetEntries = await SubstrateQuickStorageApi.evmForeignAssets
        .assetsByIdEntries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.storageKey.inputAsBigInt(0):
            XCMMultiLocation.fromJson(json: i.response, version: version)
                .asVersioned()
    };
  }

  static Future<Map<XCMVersionedLocation, BigInt>>
      getXCMTransactorPalletDestinationFeePerSeconds(
          MetadataWithProvider provider, XCMVersion version) async {
    final locations = await SubstrateQuickStorageApi.xcmTransactor
        .destinationAssetFeePerSecondEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in locations)
        XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned(): i.response
    };
  }

  static Future<Map<BigInt, Map<String, dynamic>?>>
      getAssetsPalletMetadataIdentifierBigInt(MetadataWithProvider provider,
          {List<BigInt>? assetIds}) async {
    if (assetIds != null) {
      final assetEntries = await SubstrateQuickStorageApi.assets
          .metadata<BigInt>(
              api: provider.metadata.api,
              rpc: provider.provider,
              ids: assetIds);
      return {for (final i in assetEntries) i.$1: i.$2};
    }
    final assetEntries = await SubstrateQuickStorageApi.assets
        .metadataEnteries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsBigInt(0): i.response
    };
  }

  static Future<Map<BigInt, Map<String, dynamic>?>>
      getAssetsPalletAccountIdentifierBigInt(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          required List<BigInt> assetIds}) async {
    final assetEntries = await SubstrateQuickStorageApi.assets.account(
        api: provider.metadata.api,
        rpc: provider.provider,
        assetsIdentifier: assetIds,
        address: address);
    return {for (final i in assetEntries) i.$1: i.$2.response};
  }

  static Future<Map<BigInt, BigInt?>> getFungiblePalletBalanceIdentifierBigInt(
      {required MetadataWithProvider provider,
      required BaseSubstrateAddress address,
      required List<BigInt> assetIds}) async {
    final assetEntries = await SubstrateQuickStorageApi.fungible.balance(
        api: provider.metadata.api,
        rpc: provider.provider,
        assetsIdentifier: assetIds,
        address: address);
    return {for (final i in assetEntries) i.$1: i.$2.response};
  }

  static Future<List<XCMVersionedLocation>> queryAcceptablePaymentAsset(
      {required MetadataWithProvider provider,
      required XCMVersion version}) async {
    final result = await SubstrateQuickRuntimeApi.xcmPayment
        .tryQueryAcceptablePaymentAsset(
            api: provider.metadata.api,
            rpc: provider.provider,
            version: version);
    return result.assets
        .map((e) => e.asset.location?.asVersioned(version: version))
        .whereType<XCMVersionedLocation>()
        .toList();
  }

  static Future<Map<XCMVersionedLocation, Map<String, dynamic>>>
      getForeignAssetsPalletAssetIdentifierMultiLocation(
          MetadataWithProvider provider, XCMVersion version,
          {List<XCMVersionedLocation>? assetIds}) async {
    if (assetIds != null) {
      List<(XCMVersionedLocation, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.foreignAssets.assets(
              api: provider.metadata.api,
              rpc: provider.provider,
              locations: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();
      return {for (final i in assetEntries) i.$1: i.$2!};
    }
    final assetEntries = await SubstrateQuickStorageApi.foreignAssets
        .assetEnteries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned(): i.response
    };
  }

  static Future<Map<XCMVersionedLocation, Map<String, dynamic>>>
      getFungiblesPalletAssetsIdentifierMultiLocation(
          MetadataWithProvider provider, XCMVersion version,
          {List<XCMVersionedLocation>? assetIds}) async {
    if (assetIds != null) {
      List<(XCMVersionedLocation, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.fungibles.assets(
              api: provider.metadata.api,
              rpc: provider.provider,
              locations: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();
      return {for (final i in assetEntries) i.$1: i.$2!};
    }
    final assetEntries = await SubstrateQuickStorageApi.fungibles
        .assetEnteries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned(): i.response
    };
  }

  static Future<Map<XCMVersionedLocation, Map<String, dynamic>?>>
      getForeignAssetsPalletMetadataIdentifierMultiLocation(
          MetadataWithProvider provider, XCMVersion version,
          {List<XCMVersionedLocation>? locations}) async {
    if (locations != null) {
      final metadataEntries = await SubstrateQuickStorageApi.foreignAssets
          .metadata(
              api: provider.metadata.api,
              rpc: provider.provider,
              locations: locations);
      return {for (final i in metadataEntries) i.$1: i.$2};
    }

    final assetEntries = await SubstrateQuickStorageApi.foreignAssets
        .metadataEnteries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned(): i.response
    };
  }

  static Future<Map<XCMVersionedLocation, Map<String, dynamic>?>>
      getFungiblesPalletMetadataIdentifierMultiLocation(
          MetadataWithProvider provider, XCMVersion version,
          {List<XCMVersionedLocation>? locations}) async {
    if (locations != null) {
      final metadataEntries = await SubstrateQuickStorageApi.fungibles.metadata(
          api: provider.metadata.api,
          rpc: provider.provider,
          locations: locations);
      return {for (final i in metadataEntries) i.$1: i.$2};
    }

    final assetEntries = await SubstrateQuickStorageApi.fungibles
        .metadataEnteries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned(): i.response
    };
  }

  static Future<Map<XCMVersionedLocation, Map<String, dynamic>?>>
      getForeignAssetsPalletAccountIdentifierMultilocation(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          required List<XCMVersionedLocation> locations}) async {
    final assetEntries = await SubstrateQuickStorageApi.foreignAssets.account(
        api: provider.metadata.api,
        rpc: provider.provider,
        locations: locations,
        address: address);
    return {for (final i in assetEntries) i.$1: i.$2.response};
  }

  static Future<Map<XCMVersionedLocation, Map<String, dynamic>?>>
      getFungiblesPalletAccountIdentifierMultilocation(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          required List<XCMVersionedLocation> locations}) async {
    final assetEntries = await SubstrateQuickStorageApi.fungibles.account(
        api: provider.metadata.api,
        rpc: provider.provider,
        locations: locations,
        address: address);
    return {for (final i in assetEntries) i.$1: i.$2.response};
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getXcAssetConfigPalletAssetIdToLocationEntriesIdentifierBigInt(
          MetadataWithProvider provider, XCMVersion version) async {
    final locations = await SubstrateQuickStorageApi.xcAssetConfig
        .assetIdToLocationEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in locations)
        i.storageKey.inputAsBigInt(0):
            XCMVersionedLocation.fromJson(i.response).asVersion(version)
    };
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getAssetRegistryPalletAssetIdLocationEntriesIdentifierBigInt(
          MetadataWithProvider provider, XCMVersion version) async {
    final locations = await SubstrateQuickStorageApi.assetRegistry
        .assetIdToLocationEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in locations)
        i.storageKey.inputAsBigInt(0):
            XCMMultiLocation.fromJson(json: i.response, version: version)
                .asVersioned()
    };
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getAssetManagerPalletAssetIdTypeEntriesIdentifierBigInt(
          MetadataWithProvider provider, XCMVersion version,
          {XCMVersion? palletXCMVersion}) async {
    final locations = await SubstrateQuickStorageApi.assetManager
        .assetIdTypeEntries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in locations)
        i.storageKey.inputAsBigInt(0): XCMMultiLocation.fromJson(
                json: i.response.valueAs("Xcm"),
                version: palletXCMVersion ?? version)
            .asVersion(version)
            .asVersioned()
    };
  }

  static Future<List<XCMVersionedLocation>>
      getAssetManagerPalletSupportedFeePaymentAssets(
          MetadataWithProvider provider, XCMVersion version,
          {XCMVersion? palletXCMVersion}) async {
    final locations = await SubstrateQuickStorageApi.assetManager
        .supportedFeePaymentAssets(
            api: provider.metadata.api, rpc: provider.provider);
    return locations.response
        .map((e) => XCMMultiLocation.fromJson(
                json: e.valueAs("Xcm"), version: palletXCMVersion ?? version)
            .asVersion(version)
            .asVersioned())
        .toList();
  }

  static Future<Map<XCMVersionedLocation, (bool, BigInt)>>
      getXcmWeightTraderPalletSupportedAssetsEntriesIdentifierXCMMultiLication(
          MetadataWithProvider provider, XCMVersion version,
          {XCMVersion? palletXCMVersion}) async {
    final locations = await SubstrateQuickStorageApi.xcmWeightTrader
        .supportedAssets(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in locations)
        XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0),
                version: palletXCMVersion ?? version)
            .asVersion(version)
            .asVersioned(): i.response
    };
  }

  static Future<Map<XCMVersionedLocation, BigInt>>
      getXcAssetConfigPalletAssetLocationUnitsPerSecondEntriesIdentifierMultilocation(
          MetadataWithProvider provider, XCMVersion version) async {
    final locations = await SubstrateQuickStorageApi.xcAssetConfig
        .assetLocationUnitsPerSecondEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in locations)
        XCMVersionedLocation.fromJson(i.storageKey.inputAsMap(0))
            .asVersion(version): i.response
    };
  }

  static Future<List<Map<String, dynamic>>>
      getTokenPalletTotalIssuanceIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.tokens
        .totalIssuanceEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return assetEntries
        .map((e) => e.storageKey.inputAsMap<String, dynamic>(0))
        .toList();
  }

  static Future<List<Map<String, dynamic>>>
      getOrmlTokensPalletTotalIssuanceIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.ormlTokens
        .totalIssuanceEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return assetEntries
        .map((e) => e.storageKey.inputAsMap<String, dynamic>(0))
        .toList();
  }

  static Future<Map<Map<String, dynamic>, Map<String, dynamic>>>
      getAssetRegistryPalletAssetMetadatasIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .assetMetadatasEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(0): i.response
    };
  }

  static Future<Map<Map<String, dynamic>, Map<String, dynamic>>>
      getAssetRegistryPalletAssetMetadataIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .assetMetadatasEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(0): i.response
    };
  }

  static Future<Map<Map<String, dynamic>, Map<String, dynamic>>>
      getAssetRegistryPalletcurrencyMetadatasEntriesIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .currencyMetadatasEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(0): i.response
    };
  }

  static Future<Map<Map<String, dynamic>, Map<String, dynamic>>>
      getPalletOrmlAssetRegistryMetadataIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.ormlAssetRegistry
        .metadataEntries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(0): i.response
    };
  }

  static Future<Map<Map<String, dynamic>, Map<String, dynamic>>>
      getPalletAssetRegistryMetadataIdentifierMap(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .metadataEntries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(0): i.response
    };
  }

  static Future<Map<int, Map<String, dynamic>?>>
      getAssetRegistryPalletMetadataIdentifierInt(MetadataWithProvider provider,
          {List<int>? knownIds}) async {
    if (knownIds != null) {
      final assetEntries = await SubstrateQuickStorageApi.assetRegistry
          .metadata<int, Map<String, dynamic>>(
              api: provider.metadata.api,
              rpc: provider.provider,
              assetIds: knownIds);
      return {for (final i in assetEntries) i.$1: i.$2};
    }
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .metadataEntries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsInt(0): i.response
    };
  }

  static Future<Map<Map<String, dynamic>, XCMVersionedLocation>>
      getAssetRegistryPalletLocationToCurrencyIdsEntriesIdentifierMap(
          MetadataWithProvider provider, XCMVersion version,
          {XCMVersion? palletXCMVersion}) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .locationToCurrencyIdsEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.response: XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0),
                version: palletXCMVersion ?? version)
            .asVersioned(version: version)
    };
  }

  static Future<Map<Map<String, dynamic>, XCMVersionedLocation>>
      getAssetRegistryPalletCurrencyIdToLocationsEntriesIdentifierMap(
          MetadataWithProvider provider, XCMVersion version) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .currencyIdToLocationsEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.storageKey.inputAsMap(0):
            XCMMultiLocation.fromJson(json: i.response, version: version)
                .asVersioned(version: version)
    };
  }

  /// currencyIdToLocationsEntries
  static Future<Map<Map<String, dynamic>, Map<String, dynamic>?>>
      getTokensPalletAccountIdentifierMap(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          List<Map<String, dynamic>>? assetIds}) async {
    if (assetIds != null) {
      List<(Map<String, dynamic>, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.tokens
              .accounts<Map<String, dynamic>, Map<String, dynamic>>(
                  api: provider.metadata.api,
                  rpc: provider.provider,
                  address: address,
                  assetIds: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();
      return {for (final i in assetEntries) i.$1: i.$2};
    }
    final assetEntries = await SubstrateQuickStorageApi.tokens
        .accountsEntries<Map<String, dynamic>>(
            api: provider.metadata.api,
            rpc: provider.provider,
            address: address);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(1): i.response
    };
  }

  static Future<Map<Map<String, dynamic>, Map<String, dynamic>?>>
      getOrmlTokensPalletAccountIdentifierMap(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          List<Map<String, dynamic>>? assetIds}) async {
    if (assetIds != null) {
      List<(Map<String, dynamic>, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.ormlTokens
              .accounts<Map<String, dynamic>, Map<String, dynamic>>(
                  api: provider.metadata.api,
                  rpc: provider.provider,
                  address: address,
                  assetIds: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();
      return {for (final i in assetEntries) i.$1: i.$2};
    }
    final assetEntries = await SubstrateQuickStorageApi.tokens
        .accountsEntries<Map<String, dynamic>>(
            api: provider.metadata.api,
            rpc: provider.provider,
            address: address);
    return {
      for (final i in assetEntries) i.storageKey.inputAsMap(1): i.response
    };
  }

  static Future<Map<String, dynamic>?>
      getTokensPalletAccountSignleAssetIdentifierMap(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          required Map<String, dynamic> assetId}) async {
    List<(Map<String, dynamic>, Map<String, dynamic>?)> assetEntries =
        await SubstrateQuickStorageApi.tokens
            .accounts<Map<String, dynamic>, Map<String, dynamic>>(
                api: provider.metadata.api,
                rpc: provider.provider,
                address: address,
                assetIds: [assetId]);
    return assetEntries.firstOrNull?.$2;
  }

  static Future<Map<BigInt, Map<String, dynamic>>>
      getAssetRegisteryPalletAssetsIdentifierBigInt(
          MetadataWithProvider provider,
          {List<BigInt>? assetIds}) async {
    if (assetIds != null) {
      List<(BigInt, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.assetRegistry
              .assets<BigInt, Map<String, dynamic>>(
                  api: provider.metadata.api,
                  rpc: provider.provider,
                  assetIds: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();

      return {for (final i in assetEntries) i.$1: i.$2!};
    }
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .assetsEntries(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsBigInt(0): i.response
    };
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getAssetRegistryPalletAssetLocationsIdentifierBigInt(
          MetadataWithProvider provider, XCMVersion version,
          {XCMVersion? palletXCMVersion}) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .assetLocationsEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.storageKey.inputAsBigInt(0): XCMMultiLocation.fromJson(
                json: i.response, version: palletXCMVersion ?? version)
            .asVersioned(version: version)
    };
  }

  static Future<Map<BigInt, Map<String, dynamic>>>
      tryGetAssetRegistryPalletAssetMetadataMapIdentifierBigInt(
          MetadataWithProvider provider) async {
    if (SubstrateQuickStorageApi.assetRegistry.isSupported(
        provider.metadata.api,
        SubstrateStorageAssetRegistryMethods.assetMetadataMap.name)) {
      final assetEntries = await SubstrateQuickStorageApi.assetRegistry
          .assetMetadataMapEntries(
              api: provider.metadata.api, rpc: provider.provider);
      return {
        for (final i in assetEntries) i.storageKey.inputAsBigInt(0): i.response
      };
    }
    return {};
  }

  static Future<Map<BigInt, Map<String, dynamic>?>>
      getTokensPalletAccountIdentifierBigInt(
          {required MetadataWithProvider provider,
          required BaseSubstrateAddress address,
          List<BigInt>? assetIds}) async {
    if (assetIds != null) {
      List<(BigInt, Map<String, dynamic>?)> assetEntries =
          await SubstrateQuickStorageApi.tokens
              .accounts<BigInt, Map<String, dynamic>>(
                  api: provider.metadata.api,
                  rpc: provider.provider,
                  address: address,
                  assetIds: assetIds);
      assetEntries = assetEntries.where((e) => e.$2 != null).toList();
      return {for (final i in assetEntries) i.$1: i.$2};
    }
    final assetEntries = await SubstrateQuickStorageApi.tokens
        .accountsEntries<Map<String, dynamic>>(
            api: provider.metadata.api,
            rpc: provider.provider,
            address: address);
    return {
      for (final i in assetEntries) i.storageKey.inputAsBigInt(1): i.response
    };
  }

  static Future<Map<int, XCMVersionedLocation>>
      getAssetRegistryPalletLocationToAssetIdEntriesIdentifierMap(
          MetadataWithProvider provider, XCMVersion version) async {
    final assetEntries = await SubstrateQuickStorageApi.assetRegistry
        .locationToAssetIdEntries<int>(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.response: XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned(version: version)
    };
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getAssetManagerPalletAssetIdLocationEntriesIdentifierMap(
          MetadataWithProvider provider, XCMVersion version) async {
    final assetEntries = await SubstrateQuickStorageApi.assetManager
        .assetIdLocationEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.storageKey.inputAsBigInt(0):
            XCMVersionedLocation.fromJson(i.response).asVersion(version)
    };
  }

  static Future<Map<BigInt, BigInt>>
      getAssetManagerPalletUnitsPerSecondEntriesIdentifierMap(
          MetadataWithProvider provider, XCMVersion version) async {
    final assetEntries = await SubstrateQuickStorageApi.assetManager
        .unitsPerSecondEntries(
            api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsBigInt(0): i.response
    };
  }

  static Future<Map<BigInt, XCMVersionedLocation>>
      getAssetsRegistryPalletIdByLocationsIdentifierMap(
          MetadataWithProvider provider, XCMVersion version) async {
    final assetEntries = await SubstrateQuickStorageApi.assetsRegistry
        .idByLocations(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries)
        i.response: XCMMultiLocation.fromJson(
                json: i.storageKey.inputAsMap(0), version: version)
            .asVersioned()
    };
  }

  static Future<Map<BigInt, Map<String, dynamic>>>
      getAssetsRegistryPalletRegistryInfoByIds(
          MetadataWithProvider provider) async {
    final assetEntries = await SubstrateQuickStorageApi.assetsRegistry
        .registryInfoByIds(api: provider.metadata.api, rpc: provider.provider);
    return {
      for (final i in assetEntries) i.storageKey.inputAsBigInt(0): i.response
    };
  }

  static List<IDENTIFIER>? toAssetId<IDENTIFIER extends Object?>(
      List<Object>? ids) {
    if (ids == null) return null;
    try {
      return ids.map((e) => JsonParser.valueAs<IDENTIFIER>(e)).toList();
    } catch (_) {}
    throw CastFailedException(
        message: "Failed to cast asset id as $IDENTIFIER.",
        details: {"ids": ids});
  }
}
