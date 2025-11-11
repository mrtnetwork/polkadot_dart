import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/core/api.dart';
import 'package:polkadot_dart/src/api/models/models/storage.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

const String _rpcJsonStorageChangesKey = "changes";
const String _rpcJsonBlockKey = "block";

/// Extension to assist with querying storage based on metadata
extension QueryHelper on MetadataApi {
  // /// Function to generate storage key based on pallet name/index, method name, value, and template

  @Deprecated("Use `getStorageRequest` instead.")
  Future<QueryStorageResponse<T>> getStorage<T>(
      {required QueryStorageRequest<T> request,
      required SubstrateProvider rpc,
      required bool fromTemplate,
      String? atBlockHash}) async {
    final storageKey = generateStorageKey(
        methodName: request.methodName,
        palletNameOrIndex: request.palletNameOrIndex,
        value: request.input,
        fromTemplate: fromTemplate);
    final rpcMethod =
        SubstrateRequestGetStorage(storageKey.key, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    final List<int>? queryResponse = BytesUtils.tryFromHexString(response);
    final T storageData = decodeStorageOutput(
        palletNameOrIndex: request.palletNameOrIndex,
        methodName: request.methodName,
        queryResponse: queryResponse);
    return request.toResponse(storageData);
  }

  @Deprecated("Use `queryStorageAtBlock` instead.")
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

  @Deprecated("Use `queryStorageFromBlock` instead.")
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

  @Deprecated("")
  Future<List<QueryStorageRequestBlock>> _queryStorage<T>(
      {required List<QueryStorageRequest> requestes,
      required SubstrateProvider rpc,
      required bool fromTemplate,
      String? fromBlock,
      String? atBlockHash}) async {
    final List<String> storageKeys = [];
    for (int i = 0; i < requestes.length; i++) {
      final QueryStorageRequest request = requestes[i];

      final storageKey = generateStorageKey(
          methodName: request.methodName,
          palletNameOrIndex: request.palletNameOrIndex,
          value: request.input,
          fromTemplate: fromTemplate);
      storageKeys.add(storageKey.key);
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
        final T storageData = decodeStorageOutput(
            palletNameOrIndex: request.palletNameOrIndex,
            methodName: request.methodName,
            queryResponse: queryResponse);
        results.add(request.toResponse(storageData));
      }
      blockResult.add(QueryStorageRequestBlock(request: results, block: block));
    }
    return blockResult;
  }

  Future<RESPONSE> getStorageRequest<RESPONSE extends Object?,
          DECODEDRESPONSE extends Object>(
      {required GetStorageRequest<RESPONSE, DECODEDRESPONSE> request,
      required SubstrateProvider rpc,
      bool fromTemplate = false,
      String? atBlockHash}) async {
    final storageKey = generateStorageKey(
        methodName: request.methodName,
        palletNameOrIndex: request.palletNameOrIndex,
        value: request.inputs,
        fromTemplate: fromTemplate,
        onEncodeInputs: request.onEncodeInputs);
    final rpcMethod =
        SubstrateRequestGetStorage(storageKey.key, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    final List<int>? queryResponse = BytesUtils.tryFromHexString(response);
    return request.toResponse(
        bytes: queryResponse,
        storageKey: storageKey,
        decode: () => decodeStorageOutput(
            palletNameOrIndex: request.palletNameOrIndex,
            methodName: request.methodName,
            queryResponse: queryResponse));
  }

  Future<QueryStorageResponses<RESPONSE>>
      queryStorageAtBlock<RESPONSE extends Object?, JSON extends Object>(
          {required List<GetStorageRequest<RESPONSE, JSON>> requestes,
          required SubstrateProvider rpc,
          bool fromTemplate = false,
          String? atBlockHash}) async {
    final result = await _query<RESPONSE, JSON>(
        requestes: requestes,
        rpc: rpc,
        fromTemplate: fromTemplate,
        atBlockHash: atBlockHash);
    if (result.isEmpty) return QueryStorageResponses<RESPONSE>();
    return result[0];
  }

  Future<List<QueryStorageResponses>> queryStorageFromBlock<T>(
      {required List<GetStorageRequest> requestes,
      required SubstrateProvider rpc,
      required String fromBlock,
      required bool fromTemplate,
      String? toBlock}) {
    return _query(
        requestes: requestes,
        rpc: rpc,
        fromBlock: fromBlock,
        atBlockHash: toBlock,
        fromTemplate: fromTemplate);
  }

  QueryStorageResult<RESPONSE>
      _parseQuery<RESPONSE extends Object?, DECODEDRESPONSE extends Object>({
    required List<int>? bytes,
    required String palletName,
    required String methodName,
    required StorageKey storageKey,
    ONSTORAGERESPONEBYTES<RESPONSE>? onBytesResponse,
    ONSTORAGERESPONEJSON<RESPONSE, DECODEDRESPONSE>? onJsonResponse,
    required ONSTORAGERESPONENULL<RESPONSE>? onNullResponse,
  }) {
    final RESPONSE response = () {
      if (bytes == null) {
        if (onNullResponse != null) {
          return onNullResponse(storageKey);
        }
        if (null is RESPONSE) {
          return null as RESPONSE;
        }

        throw DartSubstratePluginException('Unexpected response type.',
            details: {"excpected": "$RESPONSE", "value": 'Null'});
      }
      if (onBytesResponse != null) {
        return onBytesResponse(bytes, storageKey);
      }
      final json = decodeStorageOutput(
          palletNameOrIndex: palletName,
          methodName: methodName,
          queryResponse: bytes);

      if (json == null) {
        if (null is RESPONSE) return null as RESPONSE;
        throw DartSubstratePluginException('Unexpected response type.',
            details: {"excpected": "$RESPONSE", "value": 'Null'});
      }
      // final onJsonResponse = this.onJsonResponse;
      if (onJsonResponse != null) {
        DECODEDRESPONSE data;
        try {
          data = json as DECODEDRESPONSE;
        } catch (_) {
          throw DartSubstratePluginException('Unexpected response type.',
              details: {
                "excpected": "$DECODEDRESPONSE",
                "value": json.runtimeType
              });
        }

        return onJsonResponse(data, bytes, storageKey);
      }
      RESPONSE data;
      try {
        data = json as RESPONSE;
      } catch (_) {
        throw DartSubstratePluginException('Unexpected response type.',
            details: {"excpected": "$RESPONSE", "value": json.runtimeType});
      }
      return data;
    }();
    return QueryStorageResult<RESPONSE>(
        storageKey: storageKey, result: response);
  }

  Future<List<QueryStorageResponses<RESPONSE>>>
      _query<RESPONSE extends Object?, JSON extends Object>(
          {required List<GetStorageRequest<RESPONSE, JSON>> requestes,
          required SubstrateProvider rpc,
          required bool fromTemplate,
          String? fromBlock,
          String? atBlockHash}) async {
    final List<StorageKey> storageKeys = [];
    for (int i = 0; i < requestes.length; i++) {
      final GetStorageRequest request = requestes[i];

      final storageKey = generateStorageKey(
          methodName: request.methodName,
          palletNameOrIndex: request.palletNameOrIndex,
          value: request.inputs,
          fromTemplate: fromTemplate,
          onEncodeInputs: request.onEncodeInputs);
      storageKeys.add(storageKey);
    }
    final rpcMethod = fromBlock == null
        ? SubstrateRequestQuerStateStorageAt([...storageKeys.map((e) => e.key)],
            atBlockHash: atBlockHash)
        : SubstrateRequestStateQueryStorage(
            keys: [...storageKeys.map((e) => e.key)],
            fromBlock: fromBlock,
            toBlock: atBlockHash);
    final List<QueryStorageResponses<RESPONSE>> blockResult = [];
    final response = await rpc.request(rpcMethod);
    for (int i = 0; i < response.length; i++) {
      final Map<String, dynamic> result = (response[i] as Map).cast();
      final block = result[_rpcJsonBlockKey];
      final changes = StorageChangeStateResponse(
          (result[_rpcJsonStorageChangesKey] as List)
              .map((e) => List<String?>.from(e))
              .toList()
              .cast());
      final List<QueryStorageResult<RESPONSE>> results = [];
      for (int i = 0; i < requestes.length; i++) {
        final GetStorageRequest<RESPONSE, JSON> request = requestes[i];
        final StorageKey storageKey = storageKeys[i];
        final List<int>? queryResponse = changes.getValue(storageKey.key);
        results.add(_parseQuery<RESPONSE, JSON>(
            bytes: queryResponse,
            storageKey: storageKey,
            palletName: request.palletNameOrIndex,
            methodName: request.methodName,
            onBytesResponse: request.onBytesResponse,
            onJsonResponse: request.onJsonResponse,
            onNullResponse: request.onNullResponse));
      }
      blockResult.add(QueryStorageResponses(results: results, block: block));
    }
    return blockResult;
  }

  Future<FrameSupportDispatchPerDispatchClass> queryBlockWeight(
    SubstrateProvider rpc, {
    String? atBlockHash,
  }) async {
    final storageKey = generateStorageKey(
        methodName: MetadataConstant.queryBlockWeightMethodName,
        palletNameOrIndex: MetadataConstant.genericSystemPalletName,
        value: [],
        fromTemplate: false);
    final rpcMethod =
        SubstrateRequestGetStorage(storageKey.key, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    final List<int>? queryResponse = BytesUtils.tryFromHexString(response);
    final decodeResponse = decodeStorageOutput<Map<String, dynamic>>(
        methodName: MetadataConstant.queryBlockWeightMethodName,
        palletNameOrIndex: MetadataConstant.genericSystemPalletName,
        queryResponse: queryResponse);
    return FrameSupportDispatchPerDispatchClass.deserializeJson(decodeResponse);
  }

  Future<List<StorageKey>> getPagesStorageKeys({
    required String palletNameOrIndex,
    required String methodName,
    required SubstrateProvider rpc,
    String? storageKey,
    Object? inputs,
    int count = 1000,
    String? atBlockHash,
    String? startKey,
  }) async {
    storageKey ??= generateStorageKey(
            palletNameOrIndex: palletNameOrIndex,
            methodName: methodName,
            value: inputs,
            partial: true)
        .key;
    // ??
    //     metadata.getStoragePrefixHash(palletNameOrIndex, methodName).keyHex;
    final rpcMethod = SubstrateRequestStateGetKeysPaged(
        key: storageKey,
        atBlockHash: atBlockHash,
        count: count,
        startKey: startKey);
    final keys = await rpc.request(rpcMethod);
    List<StorageKey> storageKeys = [];
    for (final i in keys) {
      try {
        final key = decodeStorageKey(
            palletNameOrIndex: palletNameOrIndex,
            methodName: methodName,
            storageKey: i);
        storageKeys.add(key);
      } catch (_) {
        continue;
      }
    }

    return storageKeys;
  }

  Stream<List<StorageKey>> getStreamPagesStorageKeys(
      {required String palletNameOrIndex,
      required String methodName,
      required SubstrateProvider rpc,
      int count = 1000,
      String? atBlockHash,
      String? startKey}) async* {
    if (count <= 0) return;
    while (true) {
      final prefixHash =
          metadata.getStoragePrefixHash(palletNameOrIndex, methodName);
      final rpcMethod = SubstrateRequestStateGetKeysPaged(
          key: prefixHash.keyHex,
          atBlockHash: atBlockHash,
          count: count,
          startKey: startKey);
      final keys = await rpc.request(rpcMethod);
      List<StorageKey> storageKeys = [];
      for (final i in keys) {
        try {
          final key = decodeStorageKey(
              palletNameOrIndex: palletNameOrIndex,
              methodName: methodName,
              storageKey: i);
          storageKeys.add(key);
        } catch (_) {
          continue;
        }
      }
      yield storageKeys;
      if (keys.length < count) return;
      startKey = keys.lastOrNull;
    }
  }

  Future<QueryStorageResponses<RESPONSE>> getStorageEntries<
          RESPONSE extends Object?, DECODEDRESPONSE extends Object>(
      {required GetStorageEntriesRequest<RESPONSE, DECODEDRESPONSE> request,
      required SubstrateProvider rpc,
      String? atBlockHash}) async {
    final storageKeys = await getPagesStorageKeys(
        palletNameOrIndex: request.palletNameOrIndex,
        methodName: request.methodName,
        atBlockHash: atBlockHash,
        count: request.count ?? 10000,
        startKey: request.startKey,
        rpc: rpc,
        storageKey: request.storageKey,
        inputs: request.inputs);
    final rpcMethod = SubstrateRequestQuerStateStorageAt(
        [...storageKeys.map((e) => e.key)],
        atBlockHash: atBlockHash);
    final List<QueryStorageResponses<RESPONSE>> blockResult = [];
    final response = await rpc.request(rpcMethod);
    for (int i = 0; i < response.length; i++) {
      final Map<String, dynamic> result = (response[i] as Map).cast();
      final block = result[_rpcJsonBlockKey];
      final changes = StorageChangeStateResponse(
          (result[_rpcJsonStorageChangesKey] as List)
              .map((e) => List<String?>.from(e))
              .toList()
              .cast());

      final List<QueryStorageResult<RESPONSE>> results = [];
      for (int i = 0; i < storageKeys.length; i++) {
        final String storageKey = storageKeys[i].key;
        final List<int>? queryResponse = changes.getValue(storageKey);
        StorageKey storage;
        try {
          storage = decodeStorageKey(
              palletNameOrIndex: request.palletNameOrIndex,
              methodName: request.methodName,
              storageKey: storageKey);
        } catch (e) {
          continue;
        }
        results.add(_parseQuery<RESPONSE, DECODEDRESPONSE>(
            bytes: queryResponse,
            storageKey: storage,
            palletName: request.palletNameOrIndex,
            methodName: request.methodName,
            onBytesResponse: request.onBytesResponse,
            onJsonResponse: request.onJsonResponse,
            onNullResponse: request.onNullResponse));
      }
      blockResult.add(QueryStorageResponses(results: results, block: block));
    }
    if (blockResult.isEmpty) {
      return QueryStorageResponses<RESPONSE>();
    }
    return blockResult[0];
  }

  Stream<QueryStorageResponses<RESPONSE>> getStreamStorageEntries<
      RESPONSE extends Object?, DECODEDRESPONSE extends Object>({
    required GetStreamStorageEntriesRequest<RESPONSE, DECODEDRESPONSE> request,
    required SubstrateProvider rpc,
    String? atBlockHash,
  }) async* {
    int total = 0;
    String? startKey;
    int count() {
      final max = request.total;
      if (max == null) return request.count;
      final r = max - total;
      assert(r > 0);
      if (r < request.count) return r.abs();
      return request.count;
    }

    final String storageKey = request.storageKey ??
        generateStorageKey(
          palletNameOrIndex: request.palletNameOrIndex,
          methodName: request.methodName,
          partial: true,
          value: request.inputs,
          onEncodeInputs: request.onEncodeInputs,
        ).key;
    while (true) {
      final result = await getStorageEntries(
          request: GetStorageEntriesRequest<RESPONSE, DECODEDRESPONSE>.paged(
              palletNameOrIndex: request.palletNameOrIndex,
              methodName: request.methodName,
              count: count(),
              startKey: startKey,
              onBytesResponse: request.onBytesResponse,
              onJsonResponse: request.onJsonResponse,
              storageKey: storageKey),
          atBlockHash: atBlockHash,
          rpc: rpc);
      yield result;
      total += result.results.length;
      if (result.results.length < request.count) break;
      final int? max = request.total;
      if (max != null && total >= max) break;
      startKey = result.results.last.storageKey.key;
    }
  }

  Stream<QueryStorageResponses<RESPONSE>>
      queryStreamStorageAtBlock<RESPONSE extends Object?, JSON extends Object>(
          {required Stream<List<GetStorageRequest<RESPONSE, JSON>>> requestes,
          required SubstrateProvider rpc,
          bool fromTemplate = false,
          String? atBlockHash}) async* {
    await for (final i in requestes) {
      final result =
          await _query(requestes: i, rpc: rpc, fromTemplate: fromTemplate);
      if (result.isEmpty) {
        yield QueryStorageResponses<RESPONSE>();
      } else {
        yield result[0];
      }
    }
  }
}
