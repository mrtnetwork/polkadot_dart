import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/models/xcm/xcm.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageForeignAssetsMethods {
  asset("Asset"),
  metadata("Metadata"),
  account("Account");

  final String method;
  const SubstrateStorageForeignAssetsMethods(this.method);
}

/// safexcmversion
class SubstrateStorageForeignAssets extends SubstrateStorageApi {
  const SubstrateStorageForeignAssets();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.foreignAssets;
  Future<List<QueryStorageFullResponse<Map<String, dynamic>>>> assetEnteries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<Map<String, dynamic>>,
                Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageForeignAssetsMethods.asset.name,
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

  Future<List<(XCMVersionedLocation, Map<String, dynamic>?)>> assets(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required List<XCMVersionedLocation> locations}) async {
    final query = api
        .queryStreamStorageAtBlock(
            requestes: () async* {
              yield locations
                  .map((e) => GetStorageRequest<
                          (XCMVersionedLocation, Map<String, dynamic>?),
                          Map<String, dynamic>>(
                      palletNameOrIndex: this.api.name,
                      methodName:
                          SubstrateStorageForeignAssetsMethods.asset.name,
                      onNullResponse: (storageKey) => (e, null),
                      onJsonResponse: (response, _, storageKey) {
                        return (e, response);
                      },
                      inputs: e.location.toJson()
                      // onEncodeInputs: (index, onEncode) => e.serialize(),
                      ))
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
            methodName: SubstrateStorageForeignAssetsMethods.metadata.name,
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

  Future<List<(XCMVersionedLocation, Map<String, dynamic>?)>> metadata(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required List<XCMVersionedLocation> locations}) async {
    final query = api
        .queryStreamStorageAtBlock(
            requestes: () async* {
              yield locations
                  .map((e) => GetStorageRequest<
                          (XCMVersionedLocation, Map<String, dynamic>?),
                          Map<String, dynamic>>(
                      palletNameOrIndex: this.api.name,
                      methodName:
                          SubstrateStorageForeignAssetsMethods.metadata.name,
                      onNullResponse: (storageKey) => (e, null),
                      onJsonResponse: (response, _, storageKey) {
                        return (e, response);
                      },
                      inputs: e.location.toJson()
                      // onEncodeInputs: (index, onEncode) => e.serialize(),
                      ))
                  .toList();
            }(),
            rpc: rpc,
            fromTemplate: false)
        .expand((e) => e.results);
    final result = await query.toList();
    return result.map((e) => e.result).toList();
  }

  Future<
      List<
          (
            XCMVersionedLocation,
            QueryStorageFullResponse<Map<String, dynamic>>
          )>> account(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address,
      required List<XCMVersionedLocation> locations}) async {
    if (locations.isEmpty) return [];
    final List<int> addressBytes = address.toBytes().asImmutableBytes;
    final entries = api.queryStreamStorageAtBlock(
        requestes: () async* {
          yield locations
              .map((e) => GetStorageRequest<
                      (
                        XCMVersionedLocation,
                        QueryStorageFullResponse<Map<String, dynamic>>
                      )?,
                      Map<String, dynamic>>(
                    palletNameOrIndex: this.api.name,
                    methodName:
                        SubstrateStorageForeignAssetsMethods.account.name,
                    inputs: [e, addressBytes],
                    onEncodeInputs: (index, onEncode) {
                      return switch (index) {
                        0 => e.serialize(),
                        _ => addressBytes
                      };
                    },
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
        .whereType<
            (
              XCMVersionedLocation,
              QueryStorageFullResponse<Map<String, dynamic>>
            )>()
        .toList();
  }
}
