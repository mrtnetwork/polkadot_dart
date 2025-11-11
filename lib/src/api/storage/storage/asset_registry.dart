import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageAssetRegistryMethods {
  assetIdLocation("AssetIdLocation"),
  assetLocationId("AssetLocationId"),
  assets("Assets"),
  bannedAssets("BannedAssets"),
  assetLocations("AssetLocations"),
  assetIds("AssetIds"),
  metadata("Metadata"),
  locationToAssetId("LocationToAssetId"),
  locationAssets("LocationAssets"),
  assetMetadatas("AssetMetadatas"),
  currencyMetadatas("CurrencyMetadatas"),
  currencyIdToLocations("CurrencyIdToLocations"),
  locationToCurrencyIds("LocationToCurrencyIds"),
  assetMetadataMap("AssetMetadataMap"),
  erc20IdToAddress("Erc20IdToAddress");

  final String method;
  const SubstrateStorageAssetRegistryMethods(this.method);
}

/// safexcmversion
class SubstrateStorageAssetRegistry extends SubstrateStorageApi {
  const SubstrateStorageAssetRegistry();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.assetRegistry;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetIdToLocationEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.assetIdLocation.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> assetsEntries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetRegistryMethods.assets.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<(ASSETIDS, T?)>>
      assets<ASSETIDS extends Object, T extends Object>(
          {required MetadataApi api,
          required SubstrateProvider rpc,
          required List<ASSETIDS> assetIds}) async {
    final locations = api.queryStreamStorageAtBlock<(ASSETIDS, T?), T>(
        requestes: () async* {
          yield assetIds
              .map((e) => GetStorageRequest<(ASSETIDS, T?), T>(
                  palletNameOrIndex: this.api.name,
                  methodName: SubstrateStorageAssetRegistryMethods.assets.name,
                  onNullResponse: (storageKey) => (e, null),
                  onJsonResponse: (response, bytes, storageKey) =>
                      (e, response),
                  inputs: e))
              .toList();
        }(),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      bannedAssetsEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetRegistryMethods.bannedAssets.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      locationToCurrencyIdsEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.locationToCurrencyIds.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetLocationsEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.assetLocations.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetMetadataMapEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.assetMetadataMap.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<BigInt>>> assetIdsEntries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, Object>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetRegistryMethods.assetIds.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: BigintUtils.parse(response, allowHex: false));
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> metadataEntries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetRegistryMethods.metadata.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<(ASSETIDS, T?)>>
      metadata<ASSETIDS extends Object, T extends Object>(
          {required MetadataApi api,
          required SubstrateProvider rpc,
          required List<ASSETIDS> assetIds}) async {
    final locations = api.queryStreamStorageAtBlock<(ASSETIDS, T?), T>(
        requestes: () async* {
          yield assetIds
              .map((e) => GetStorageRequest<(ASSETIDS, T?), T>(
                  palletNameOrIndex: this.api.name,
                  methodName:
                      SubstrateStorageAssetRegistryMethods.metadata.name,
                  onNullResponse: (storageKey) => (e, null),
                  onJsonResponse: (response, bytes, storageKey) =>
                      (e, response),
                  inputs: e))
              .toList();
        }(),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<T>>>
      locationToAssetIdEntries<T extends Object>(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<QueryStorageFullResponse<T>, T>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.locationToAssetId.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<T>>>
      locationAssetsEntries<T extends Object>(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<QueryStorageFullResponse<T>, T>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.locationAssets.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetMetadatasEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.assetMetadatas.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      currencyMetadatasEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.currencyMetadatas.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      currencyIdToLocationsEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.currencyIdToLocations.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<String>>> erc20IdToAddressEntries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<String>, String>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetRegistryMethods.erc20IdToAddress.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }
}
