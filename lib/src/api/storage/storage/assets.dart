import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageAssetsMethods {
  asset("Asset"),
  metadata("Metadata"),
  account("Account");

  final String method;
  const SubstrateStorageAssetsMethods(this.method);
}

/// safexcmversion
class SubstrateStorageAssets extends SubstrateStorageApi {
  const SubstrateStorageAssets();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.assets;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> assetEnteries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetsMethods.asset.name,
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

  Future<List<(T, Map<String, dynamic>?)>> assets<T extends Object>(
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
                      methodName: SubstrateStorageAssetsMethods.asset.name,
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

  Future<List<(T, Map<String, dynamic>?)>> metadata<T extends Object>(
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
                      methodName: SubstrateStorageAssetsMethods.metadata.name,
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

  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> metadataEnteries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageAssetsMethods.metadata.name,
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

  Future<List<(T, QueryStorageFullResponse<Map<String, dynamic>>)>>
      account<T extends Object>(
          {required MetadataApi api,
          required SubstrateProvider rpc,
          required BaseSubstrateAddress address,
          required List<T> assetsIdentifier}) async {
    if (assetsIdentifier.isEmpty) return [];
    final List<int> addressBytes = address.toBytes().asImmutableBytes;
    final entries = api.queryStreamStorageAtBlock(
        requestes: () async* {
          yield assetsIdentifier
              .map((e) => GetStorageRequest<
                      (T, QueryStorageFullResponse<Map<String, dynamic>>)?,
                      Map<String, dynamic>>(
                    palletNameOrIndex: this.api.name,
                    methodName: SubstrateStorageAssetsMethods.account.name,
                    inputs: [e, addressBytes],
                    onJsonResponse: (response, bytes, storageKey) => (
                      e,
                      QueryStorageFullResponse(
                          storageKey: storageKey,
                          responseBytes: bytes,
                          response: response)
                    ),
                  ))
              .toList();
        }(),
        rpc: rpc);
    final result = await entries.toList();
    return result
        .expand((e) => e.results)
        .map((e) => e.result)
        .whereType<(T, QueryStorageFullResponse<Map<String, dynamic>>)>()
        .toList();
  }
}
