import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:polkadot_dart/src/address/address.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageFungibleMethods {
  balance("balance");

  final String method;
  const SubstrateStorageFungibleMethods(this.method);
}

/// safexcmversion
class SubstrateStorageFungible extends SubstrateStorageApi {
  const SubstrateStorageFungible();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.fungible;
  Future<List<(T, QueryStorageFullResponse<BigInt>)>> balance<T extends Object>(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address,
      required List<T> assetsIdentifier}) async {
    if (assetsIdentifier.isEmpty) return [];
    final addressBytes = address.toBytes().asImmutableBytes;
    final Map<String, dynamic> addr = switch (address.type) {
      SubstrateAddressType.ethereum => {"Ethereum": addressBytes},
      SubstrateAddressType.substrate => {"Substrate": addressBytes}
    };
    final entries = api.queryStreamStorageAtBlock(
        requestes: () async* {
          yield assetsIdentifier
              .map((e) => GetStorageRequest<
                      (T, QueryStorageFullResponse<BigInt>)?, BigInt>(
                    palletNameOrIndex: this.api.name,
                    methodName: SubstrateStorageFungibleMethods.balance.name,
                    inputs: [e, addr],
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
        .whereType<(T, QueryStorageFullResponse<BigInt>)>()
        .toList();
  }
}
