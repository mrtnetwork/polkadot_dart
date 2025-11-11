import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/models/modesl.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageXCMTransactorMethods {
  destinationAssetFeePerSecond("DestinationAssetFeePerSecond");

  final String method;
  const SubstrateStorageXCMTransactorMethods(this.method);
}

/// safexcmversion
class SubstrateStorageXCMTransactor extends SubstrateStorageApi {
  const SubstrateStorageXCMTransactor();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.xcmTransactor;
  Future<List<QueryStorageFullResponse<BigInt>>>
      destinationAssetFeePerSecondEntries(
          {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, BigInt>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageXCMTransactorMethods
                .destinationAssetFeePerSecond.method,
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

  Future<List<(XCMMultiLocation, BigInt?)>>
      destinationAssetFeePerSecond<T extends Object>(
          {required MetadataApi api,
          required SubstrateProvider rpc,
          required List<XCMMultiLocation> ids}) async {
    final query = api
        .queryStreamStorageAtBlock(
            requestes: () async* {
              yield ids
                  .map((e) =>
                      GetStorageRequest<(XCMMultiLocation, BigInt?), BigInt>(
                          palletNameOrIndex: this.api.name,
                          methodName: SubstrateStorageXCMTransactorMethods
                              .destinationAssetFeePerSecond.method,
                          onNullResponse: (storageKey) => (e, null),
                          onJsonResponse: (response, _, storageKey) {
                            return (e, response);
                          },
                          inputs: e.toJson()))
                  .toList();
            }(),
            rpc: rpc,
            fromTemplate: false)
        .expand((e) => e.results);
    final result = await query.toList();
    return result.map((e) => e.result).toList();
  }
}
