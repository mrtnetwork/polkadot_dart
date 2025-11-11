import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageXcAssetConfigMethods {
  assetIdToLocation("AssetIdToLocation"),
  assetLocationToId("AssetLocationToId"),
  assetLocationUnitsPerSecond("AssetLocationUnitsPerSecond");

  final String method;
  const SubstrateStorageXcAssetConfigMethods(this.method);
}

/// safexcmversion
class SubstrateStorageXcAssetConfig extends SubstrateStorageApi {
  const SubstrateStorageXcAssetConfig();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.xcAssetConfig;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetIdToLocationEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageXcAssetConfigMethods.assetIdToLocation.name,
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

  Future<List<QueryStorageFullResponse<BigInt>>>
      assetLocationUnitsPerSecondEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, Object>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageXcAssetConfigMethods
                .assetLocationUnitsPerSecond.name,
            onJsonResponse: (response, responseBytes, storageKey) {
              return QueryStorageFullResponse(
                  storageKey: storageKey,
                  responseBytes: responseBytes,
                  response: BigintUtils.parse(response));
            }),
        rpc: rpc);
    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }
}
