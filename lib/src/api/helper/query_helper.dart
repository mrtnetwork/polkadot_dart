import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/address/substrate_address/substrate.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/models/response.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

const String _rpcJsonStorageChangesKey = "changes";
const String _rpcJsonBlockKey = "block";

extension QueryHelper on MetadataApi {
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
    required SubstrateRPC rpc,
    required bool fromTemplate,
    String? atBlockHash,
  }) async {
    final storageKey = _getStorageKey(
        methodName: request.methodName,
        palletNameOrIndex: request.palletNameOrIndex,
        value: request.input,
        fromTemplate: fromTemplate);
    final rpcMethod =
        SubstrateRPCGetStorage(storageKey, atBlockHash: atBlockHash);
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
      required SubstrateRPC rpc,
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
      required SubstrateRPC rpc,
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
      required SubstrateRPC rpc,
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
        ? SubstrateRPCQuerStateStorageAt([...storageKeys],
            atBlockHash: atBlockHash)
        : SubstrateRPCStateQueryStorage(
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
    required SubstrateAddress multisigaddress,
    required List<int> callHashTx,
    required SubstrateRPC rpc,
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

  Future<SubstrateAccountInfo> getAccountInfo(
      {required SubstrateAddress address, required SubstrateRPC rpc}) async {
    final data = await getStorage(
        request: QueryStorageRequest<Map<String, dynamic>>(
            palletNameOrIndex: "System",
            methodName: "account",
            input: address.toBytes(),
            identifier: 0),
        rpc: rpc,
        fromTemplate: false);
    return SubstrateAccountInfo.deserializeJson(data.result);
  }
}
