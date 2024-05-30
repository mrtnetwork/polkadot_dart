import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/api/models/response.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/imp/api_interface.dart';
import 'package:polkadot_dart/src/metadata/imp/metadata_interface.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/provider/provider.dart';

const String _rpcJsonStorageChangesKey = "changes";
const String _rpcJsonBlockKey = "block";

class MetadataApi with MetadataApiInterface {
  final LatestMetadataInterface metadata;
  const MetadataApi(this.metadata);

  PortableRegistry get registry => metadata.registry;
  @override
  int getPalletIndexByName(String name) => metadata.getPalletIndex(name);

  @override
  String getPalletNameByIndex(int index) =>
      metadata.getPalletName(index.toString());

  @override
  TypeTemlate getLookupTemplate(int id) {
    return registry.typeTemplate(id);
  }

  @override
  TypeTemlate getCallTemplate(String palletNameOrIndex) {
    return getLookupTemplate(metadata.getCallLookupId(palletNameOrIndex));
  }

  @override
  List<int> encodeCall(
      {required String palletNameOrIndex,
      required Object? value,
      required bool fromTemplate}) {
    final toBytes = encodeLookup(
        id: metadata.getCallLookupId(palletNameOrIndex),
        value: value,
        fromTemplate: fromTemplate);
    return [metadata.getPalletIndex(palletNameOrIndex), ...toBytes];
  }

  @override
  List<int> encodeLookup(
      {required int id, required Object? value, required bool fromTemplate}) {
    return metadata.encodeLookup(
        id: id, value: value, fromTemplate: fromTemplate);
  }

  @override
  T decodeLookup<T>(int id, List<int> bytes) {
    final decode = metadata.decodeLookup(id, bytes);
    return decode;
  }

  @override
  T decodeCall<T>(List<int> bytes) {
    if (bytes.isEmpty) {
      throw const MessageException("Invalid encoded call bytes.");
    }
    final palletIndex = bytes[0];
    return decodeLookup(
        metadata.getCallLookupId(palletIndex.toString()), bytes.sublist(1));
  }

  @override
  T getConstant<T>(String palletNameOrIndex, String constantName) =>
      metadata.getConstant(palletNameOrIndex, constantName);

  @override
  List<int> getPalletIndexes() => metadata.getPalletIndexes();

  @override
  List<String> getPalletNames() => metadata.getPalletNames();

  @override
  Map<String, dynamic> getConstants(String palletNameOrIndex) =>
      metadata.getConstants(palletNameOrIndex);

  @override
  TypeTemlate? getStorageInputTemplate(
      String palletNameOrIndex, String methodName) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    if (lookupId == null) return null;
    return getLookupTemplate(lookupId);
  }

  @override
  TypeTemlate getStorageOutputTemplate(
      String palletNameOrIndex, String methodName) {
    final lookupId = metadata.getStorageOutputId(palletNameOrIndex, methodName);
    return getLookupTemplate(lookupId);
  }

  @override
  List<int> encodeStorageMethodInput(
      {required String palletNameOrIndex,
      required String methodName,
      required Object? value,
      required bool fromTemplate}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    if (lookupId == null) return [];
    return encodeLookup(id: lookupId, value: value, fromTemplate: fromTemplate);
  }

  @override
  T decodeStorageInput<T>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int> bytes}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    if (lookupId == null) return null as T;
    return decodeLookup(lookupId, bytes);
  }

  @override
  T decodeStorageResponse<T>(
      {required String palletNameOrIndex,
      required String methodName,
      List<int>? queryResponse}) {
    return metadata.decodeStorageOutput(
        palletNameOrIndex: palletNameOrIndex,
        methodName: methodName,
        queryResponse: queryResponse);
  }

  @override
  List<int> getStorageKey({
    required String palletNameOrIndex,
    required String methodName,
    required bool fromTemplate,
    required Object? value,
  }) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    final prefixHash =
        metadata.getStoragePrefixHash(palletNameOrIndex, methodName);
    if (lookupId == null) return prefixHash;
    final hashers = metadata.getStorageHasher(palletNameOrIndex, methodName);
    List<int> methodBytes = [];
    if (hashers.length > 1) {
      final lookup = metadata.getLookup(lookupId);
      if (lookup.typeName != Si1TypeDefsIndexesConst.tuple) {
        throw const MessageException(
            "Invalid lookup type. method with mutliple argruments must be tuple");
      }
      final List<int> lookupIds = (lookup.def as TypeDefTuple).values;

      final listValue = MetadataUtils.isList(registry.getValue(
          id: lookupId, value: value, fromTemplate: fromTemplate));
      for (int i = 0; i < hashers.length; i++) {
        final hasher = hashers[i];
        final indexValue = listValue[i];
        final type = lookupIds[i];
        final layout =
            metadata.getLookup(type).typeDefLayout(registry, indexValue);
        final encode = layout.serialize(indexValue);
        methodBytes = [...methodBytes, ...hasher.toHash(encode)];
      }
    } else {
      methodBytes =
          encodeLookup(id: lookupId, value: value, fromTemplate: fromTemplate);
      if (hashers.isNotEmpty) {
        final hasher = hashers[0];
        methodBytes = hasher.toHash(methodBytes);
      }
    }
    return [...prefixHash, ...methodBytes];
  }

  @override
  T decodeQueryStorageKey<T>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int> bytes}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    final prefixHash =
        metadata.getStoragePrefixHash(palletNameOrIndex, methodName);
    final methodBytes = MetadataUtils.getQueryBytesFromStorageKey(
        queryBytes: bytes, prefixHash: prefixHash);
    if (lookupId == null) {
      return null as T;
    }
    return decodeLookup(lookupId, methodBytes);
  }

  @override
  T decodeEvent<T>(
      {String palletNameOrIndex = MetadataConstant.genericSystemPalletName,
      required List<int> bytes,
      int? knownLookupId}) {
    final event = registry.findEventRecordLookup(knownId: knownLookupId);
    final decode = event.typeDefDecode(registry, bytes);
    return decode.value;
  }

  @override
  List<int> generateEventStorageKey(
      {String palletNameOrIndex = MetadataConstant.genericSystemPalletName}) {
    final correctName = metadata.getPalletName(palletNameOrIndex);
    return MetadataUtils.createEventPrefixHash(prefix: correctName);
  }

  @override
  TypeTemlate getEventTemplate({int? eventRecordLookupId}) {
    final event = registry.findEventRecordLookup(knownId: eventRecordLookupId);
    return event.typeTemplate(registry, event.type);
  }

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

  Future<QueryStorageResult<T>> getEvents<T>(SubstrateRPC rpc,
      {String? palletIdOrIndex, String? atBlockHash}) async {
    final List<int> storageKeyBytes = generateEventStorageKey();
    final String storageKey =
        BytesUtils.toHexString(storageKeyBytes, prefix: "0x");
    final rpcMethod =
        SubstrateRPCGetStorage(storageKey, atBlockHash: atBlockHash);
    final response = await rpc.request(rpcMethod);
    if (response == null) {
      return QueryStorageResult(storageKey: storageKey, result: null as T);
    }
    final List<int> eventBytes = BytesUtils.fromHexString(response);
    final events = decodeEvent(palletNameOrIndex: "0", bytes: eventBytes);
    return QueryStorageResult(storageKey: storageKey, result: events);
  }

  @override
  Map<String, dynamic> runtimeVersion() {
    return getConstant("System", "Version");
  }

  @override
  List<String> getPalletStorageMethods(String palletNameOrIndex) =>
      metadata.getPalletStorageMethods(palletNameOrIndex);

  @override
  String getRuntimeApiMethod(String apiName, String methodName) =>
      metadata.getRuntimeApiMethod(apiName, methodName);

  @override
  List<String> getRuntimeApiMethods(String apiName) {
    return metadata.getRuntimeApiMethods(apiName);
  }

  @override
  List<String> getRuntimeApis() {
    return metadata.getRuntimeApis();
  }

  @override
  List<int> getRuntimeApiInputLookupIds(String apiName, String methodName) {
    return metadata.getRutimeApiInputLookupIds(apiName, methodName);
  }

  @override
  int getRuntimeApiOutputLookupId(String apiName, String methodName) {
    return metadata.getRutimeOutputLookupId(apiName, methodName);
  }

  @override
  List<TypeTemlate> getRuntimeApiInputsTemplates(
      String apiName, String methodName) {
    final ids = getRuntimeApiInputLookupIds(apiName, methodName);
    return ids.map((e) => getLookupTemplate(e)).toList();
  }

  @override
  TypeTemlate getRuntimeApiOutputTemplate(String apiName, String methodName) {
    return getLookupTemplate(getRuntimeApiOutputLookupId(apiName, methodName));
  }

  @override
  List<int> encodeRuntimeApiInputs(
      {required String apiName,
      required String methodName,
      required List<Object?> params,
      bool fromTemplate = true}) {
    final method = getRuntimeApiMethod(apiName, methodName);
    final inputs = getRuntimeApiInputLookupIds(apiName, methodName);
    if (inputs.length != params.length) {
      throw MetadataException("Invalid input params length.", details: {
        "method": method,
        "paramsLength": params.length,
        "methodParams": inputs.length
      });
    }
    List<int> encodedParams = [];
    for (int i = 0; i < inputs.length; i++) {
      final encode = encodeLookup(
          id: inputs[i], value: params[i], fromTemplate: fromTemplate);
      encodedParams = [...encodedParams, ...encode];
    }
    return encodedParams;
  }

  @override
  T decodeRuntimeApiOutput<T>(
      {required String apiName,
      required String methodName,
      required List<int> bytes}) {
    final lookupId = getRuntimeApiOutputLookupId(apiName, methodName);
    return decodeLookup(lookupId, bytes);
  }

  @override
  Future<T> runtimeCall<T>(
      {required String apiName,
      required String methodName,
      required List<Object?> params,
      required SubstrateRPC rpc,
      bool fromTemplate = true}) async {
    final method = getRuntimeApiMethod(apiName, methodName);
    final encode = encodeRuntimeApiInputs(
        apiName: apiName,
        methodName: methodName,
        params: params,
        fromTemplate: fromTemplate);
    final rpcMethod = SubstrateRPCStateCall(
        method: method, data: BytesUtils.toHexString(encode, prefix: "0x"));
    final response = await rpc.request(rpcMethod);
    return decodeRuntimeApiOutput(
        apiName: apiName,
        methodName: methodName,
        bytes: BytesUtils.fromHexString(response));
  }
}
