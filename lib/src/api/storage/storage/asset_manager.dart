import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageAssetManagerMethods {
  assetIdType("AssetIdType"),
  assetIdLocation("AssetIdLocation"),
  assetTypeUnitsPerSecond("AssetTypeUnitsPerSecond"),
  supportedFeePaymentAssets("SupportedFeePaymentAssets"),
  unitsPerSecond("UnitsPerSecond");

  final String method;
  const SubstrateStorageAssetManagerMethods(this.method);
}

/// safexcmversion
class SubstrateStorageAssetManager extends SubstrateStorageApi {
  const SubstrateStorageAssetManager();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.assetManager;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetIdTypeEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetManagerMethods.assetIdType.name,
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
      assetIdLocationEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageAssetManagerMethods.assetIdLocation.name,
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

  Future<QueryStorageFullResponse<List<Map<String, dynamic>>>>
      supportedFeePaymentAssets(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = await api.getStorageRequest(
        request: GetStorageRequest<
                QueryStorageFullResponse<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetManagerMethods
                .supportedFeePaymentAssets.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: response);
            }),
        rpc: rpc);
    return locations;
  }

  Future<List<QueryStorageFullResponse<BigInt>>> assetTypeUnitsPerSecond(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, BigInt>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetManagerMethods
                .assetTypeUnitsPerSecond.name,
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

  Future<List<QueryStorageFullResponse<BigInt>>> unitsPerSecondEntries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, BigInt>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetManagerMethods.unitsPerSecond.name,
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
