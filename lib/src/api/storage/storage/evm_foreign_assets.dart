import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageEvmForeignAssetsMethods {
  assetsById("AssetsById");

  final String method;
  const SubstrateStorageEvmForeignAssetsMethods(this.method);
}

/// safexcmversion
class SubstrateStorageEvmForeignAssets extends SubstrateStorageApi {
  const SubstrateStorageEvmForeignAssets();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.evmForeignAssets;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>>
      assetsByIdEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName:
                SubstrateStorageEvmForeignAssetsMethods.assetsById.method,
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

  Future<List<(T, Map<String, dynamic>?)>> assetsById<T extends Object>(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required List<T> ids}) async {
    final query = api
        .queryStreamStorageAtBlock(
            requestes: () async* {
              yield ids
                  .map((e) => GetStorageRequest<(T, Map<String, dynamic>?),
                          Map<String, dynamic>>(
                      palletNameOrIndex: this.api.name,
                      methodName: SubstrateStorageEvmForeignAssetsMethods
                          .assetsById.method,
                      onNullResponse: (storageKey) => (e, null),
                      onJsonResponse: (response, _, storageKey) {
                        return (e, response);
                      },
                      inputs: e))
                  .toList();
            }(),
            rpc: rpc,
            fromTemplate: false)
        .expand((e) => e.results);
    final result = await query.toList();
    return result.map((e) => e.result).toList();
  }
}
