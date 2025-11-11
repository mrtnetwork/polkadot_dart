import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/helper/query_helper.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/api/storage/storage/types/types.dart';
import 'package:polkadot_dart/src/provider/provider/provider.dart';

enum SubstrateStorageSystemMethods {
  account("Account");

  final String method;
  const SubstrateStorageSystemMethods(this.method);
}

/// safexcmversion
class SubstrateStorageSystem extends SubstrateStorageApi {
  const SubstrateStorageSystem();
  @override
  SubstrateStorageApis get api => SubstrateStorageApis.system;
  Future<SubstrateAccount> account(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address}) async {
    return await api.getStorageRequest(
        request: GetStorageRequest<SubstrateAccount, Map<String, dynamic>>(
            palletNameOrIndex: this.api.name,
            methodName: SubstrateStorageSystemMethods.account.name,
            inputs: address.toBytes(),
            onNullResponse: (storageKey) => SubstrateAccount(
                nonce: BigInt.zero,
                consumers: 0,
                providers: 0,
                sufficients: 0,
                data: {}),
            onJsonResponse: (response, responseBytes, storageKey) {
              return SubstrateAccount.deserializeJson(response);
            }),
        rpc: rpc);
  }

  /// in some solo chains maybe fail because of different account frame.
  Future<SubstrateDefaultAccount> accountWithDataFrame(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address}) async {
    return await api.getStorageRequest(
        request:
            GetStorageRequest<SubstrateDefaultAccount, Map<String, dynamic>>(
                palletNameOrIndex: this.api.name,
                methodName: SubstrateStorageSystemMethods.account.name,
                inputs: address.toBytes(),
                onNullResponse: (storageKey) => SubstrateDefaultAccount(
                    nonce: BigInt.zero,
                    consumers: 0,
                    providers: 0,
                    sufficients: 0,
                    data: SubstrateAccountData(
                        flags: BigInt.zero,
                        reserved: BigInt.zero,
                        frozen: BigInt.zero,
                        free: BigInt.zero)),
                onJsonResponse: (response, responseBytes, storageKey) {
                  return SubstrateDefaultAccount.deserializeJson(response);
                }),
        rpc: rpc);
  }

  Future<BigInt> nonce(
      {required MetadataApi api,
      required SubstrateProvider rpc,
      required BaseSubstrateAddress address}) async {
    return await api.getStorageRequest(
        request: GetStorageRequest<BigInt, Map<String, dynamic>>(
          palletNameOrIndex: "System",
          methodName: "account",
          inputs: address.toBytes(),
          onNullResponse: (storageKey) => BigInt.zero,
          onJsonResponse: (response, _, __) =>
              BigintUtils.parse(response["nonce"], allowHex: false),
        ),
        rpc: rpc,
        fromTemplate: false);
  }
}
