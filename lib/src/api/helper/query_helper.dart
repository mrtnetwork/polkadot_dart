import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/models/response.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

const String _rpcJsonStorageChangesKey = "changes";
const String _rpcJsonBlockKey = "block";

/// Extension to assist with querying storage based on metadata
extension QueryHelper on MetadataApi {
  /// Function to generate storage key based on pallet name/index, method name, value, and template
  String _getStorageKey({
    required String palletNameOrIndex,
    required String methodName,
    required Object? value,
    required bool fromTemplate,
  }) {
    final queryKey = getStorageKey(
        palletNameOrIndex: palletNameOrIndex,
        methodName: methodName,
        value: value,
        fromTemplate: fromTemplate);
    return BytesUtils.toHexString(queryKey, prefix: "0x");
  }

  Future<QueryStorageResponse<T>> getStorage<T>({
    required QueryStorageRequest<T> request,
    required SubstrateProvider rpc,
    required bool fromTemplate,
    String? atBlockHash,
  }) async {
    final storageKey = _getStorageKey(
        methodName: request.methodName,
        palletNameOrIndex: request.palletNameOrIndex,
        value: request.input,
        fromTemplate: fromTemplate);
    final rpcMethod =
        SubstrateRequestGetStorage(storageKey, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    final List<int>? queryResponse = BytesUtils.tryFromHexString(response);
    final storageData = decodeStorageResponse(
        palletNameOrIndex: request.palletNameOrIndex,
        methodName: request.methodName,
        queryResponse: queryResponse);
    return request.toResponse(storageData);
  }

  Future<QueryStorageRequestBlock> queryStorageAt(
      {required List<QueryStorageRequest> requestes,
      required SubstrateProvider rpc,
      required bool fromTemplate,
      String? atBlockHash}) async {
    final result = await _queryStorage(
        requestes: requestes,
        rpc: rpc,
        fromTemplate: fromTemplate,
        atBlockHash: atBlockHash);
    return result[0];
  }

  Future<List<QueryStorageRequestBlock>> queryStorage<T>(
      {required List<QueryStorageRequest> requestes,
      required SubstrateProvider rpc,
      required String fromBlock,
      required bool fromTemplate,
      String? toBlock}) {
    return _queryStorage(
        requestes: requestes,
        rpc: rpc,
        fromBlock: fromBlock,
        atBlockHash: toBlock,
        fromTemplate: fromTemplate);
  }

  Future<List<QueryStorageRequestBlock>> _queryStorage<T>(
      {required List<QueryStorageRequest> requestes,
      required SubstrateProvider rpc,
      required bool fromTemplate,
      String? fromBlock,
      String? atBlockHash}) async {
    final List<String> storageKeys = [];
    for (int i = 0; i < requestes.length; i++) {
      final QueryStorageRequest request = requestes[i];

      final storageKey = _getStorageKey(
          methodName: request.methodName,
          palletNameOrIndex: request.palletNameOrIndex,
          value: request.input,
          fromTemplate: fromTemplate);
      storageKeys.add(storageKey);
    }
    final rpcMethod = fromBlock == null
        ? SubstrateRequestQuerStateStorageAt([...storageKeys],
            atBlockHash: atBlockHash)
        : SubstrateRequestStateQueryStorage(
            keys: [...storageKeys], fromBlock: fromBlock, toBlock: atBlockHash);
    final List<QueryStorageRequestBlock> blockResult = [];
    final response = await rpc.request(rpcMethod);
    for (int i = 0; i < response.length; i++) {
      final Map<String, dynamic> result = (response[i] as Map).cast();
      final block = result[_rpcJsonBlockKey];
      final changes = StorageChangeStateResponse(
          (result[_rpcJsonStorageChangesKey] as List)
              .map((e) => List<String?>.from(e))
              .toList()
              .cast());
      final List<QueryStorageResponse> results = [];

      for (int i = 0; i < requestes.length; i++) {
        final QueryStorageRequest request = requestes[i];
        final String storageKey = storageKeys[i];
        final List<int>? queryResponse = changes.getValue(storageKey);
        final T storageData = decodeStorageResponse(
            palletNameOrIndex: request.palletNameOrIndex,
            methodName: request.methodName,
            queryResponse: queryResponse);
        results.add(request.toResponse(storageData));
      }
      blockResult.add(QueryStorageRequestBlock(request: results, block: block));
    }
    return blockResult;
  }

  Future<Map<String, dynamic>?> getMultisigs({
    required BaseSubstrateAddress multisigaddress,
    required List<int> callHashTx,
    required SubstrateProvider rpc,
  }) async {
    final List<List<int>> template = [multisigaddress.toBytes(), callHashTx];
    final result = await getStorage(
        request: QueryStorageRequest<Map<String, dynamic>?>(
            palletNameOrIndex: "multisig",
            methodName: "Multisigs",
            input: template,
            identifier: 0),
        rpc: rpc,
        fromTemplate: false);
    return result.result;
  }

  /// should be failed in some network.
  Future<SubstrateDefaultAccount> getDefaultAccountInfo(
      {required BaseSubstrateAddress address,
      required SubstrateProvider rpc}) async {
    final data = await getStorage(
        request: QueryStorageRequest<Map<String, dynamic>>(
            palletNameOrIndex: "System",
            methodName: "account",
            input: address.toBytes(),
            identifier: 0),
        rpc: rpc,
        fromTemplate: false);
    return SubstrateDefaultAccount.deserializeJson(data.result);
  }

  Future<SubstrateAccount> getAccount(
      {required BaseSubstrateAddress address,
      required SubstrateProvider rpc}) async {
    final data = await getStorage(
        request: QueryStorageRequest<Map<String, dynamic>>(
            palletNameOrIndex: "System",
            methodName: "account",
            input: address.toBytes(),
            identifier: 0),
        rpc: rpc,
        fromTemplate: false);
    return SubstrateAccount.deserializeJson(data.result);
  }

  Future<FrameSupportDispatchPerDispatchClass> queryBlockWeight(
    SubstrateProvider rpc, {
    String? atBlockHash,
  }) async {
    final storageKey = _getStorageKey(
        methodName: MetadataConstant.queryBlockWeightMethodName,
        palletNameOrIndex: MetadataConstant.genericSystemPalletName,
        value: [],
        fromTemplate: false);
    final rpcMethod =
        SubstrateRequestGetStorage(storageKey, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    final List<int>? queryResponse = BytesUtils.tryFromHexString(response);
    final decodeResponse = decodeStorageResponse<Map<String, dynamic>>(
        methodName: MetadataConstant.queryBlockWeightMethodName,
        palletNameOrIndex: MetadataConstant.genericSystemPalletName,
        queryResponse: queryResponse);
    return FrameSupportDispatchPerDispatchClass.deserializeJson(decodeResponse);
  }
}
