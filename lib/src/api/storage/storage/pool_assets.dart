import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStoragePoolAssetsMethods {
  asset("asset"),
  metadata("metadata");

  final String method;
  const SubstrateStoragePoolAssetsMethods(this.method);
}

/// safexcmversion
class SubstrateStoragePoolAssets extends SubstrateStorageApi {
  const SubstrateStoragePoolAssets();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.poolAssets;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> assetEnteries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStoragePoolAssetsMethods.asset.name,
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

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> metadataEnteries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStoragePoolAssetsMethods.metadata.name,
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
