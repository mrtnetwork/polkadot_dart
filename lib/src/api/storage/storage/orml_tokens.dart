import 'package:blockchain_utils/helper/helper.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageOrmlTokensMethods {
  totalIssuance("TotalIssuance"),
  accounts("Accounts");

  final String method;
  const SubstrateStorageOrmlTokensMethods(this.method);
}

/// safexcmversion
class SubstrateStorageOrmlTokens extends SubstrateStorageApi {
  const SubstrateStorageOrmlTokens();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.ormlTokens;
  Future<List<QueryStorageFullResponse<BigInt>>> totalIssuanceEntries(
      {required MetadataApi api, required SubstrateProvider rpc}) async {
    final locations = api.getStreamStorageEntries(
        request: GetStreamStorageEntriesRequest<
                QueryStorageFullResponse<BigInt>, BigInt>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageOrmlTokensMethods.totalIssuance.name,
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

  Future<List<(R, T?)>> accounts<R extends Object, T extends Object>(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address,
      required List<R> assetIds}) async {
    final addressBytes = address.toBytes().asImmutableBytes;
    final locations = api.queryStreamStorageAtBlock<(R, T?), T>(
        requestes: () async* {
          yield assetIds
              .map((e) => GetStorageRequest<(R, T?), T>(
                  palletNameOrIndex: this.api.name,
                  methodName: SubstrateStorageOrmlTokensMethods.accounts.name,
                  onNullResponse: (storageKey) => (e, null),
                  onJsonResponse: (response, bytes, storageKey) =>
                      (e, response),
                  inputs: [addressBytes, e]))
              .toList();
        }(),
        rpc: rpc);

    final result = await locations.toList();
    return result.expand((e) => e.results).map((e) => e.result).toList();
  }

  Future<List<QueryStorageFullResponse<T>>> accountsEntries<T extends Object>(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address}) async {
    final addressBytes = address.toBytes().asImmutableBytes;
    final locations = api.getStreamStorageEntries(
        request:
            GetStreamStorageEntriesRequest<QueryStorageFullResponse<T>, Object>(
                palletNameOrIndex: this.api.name,
                inputs: [addressBytes],
                methodName: SubstrateStorageOrmlTokensMethods.accounts.name,
                onEncodeInputs: (index, onEncode) {
                  switch (index) {
                    case 0:
                      return addressBytes;
                    default:
                      return null;
                  }
                },
                onJsonResponse: (response, responseBytes, storageKey) {
                  if (response is! T) {
                    throw DartSubstratePluginException(
                        "Failed to cast storage response.",
                        details: {
                          "excpected": "$T",
                          "response": response.runtimeType
                        });
                  }
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
