import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/imp/api_interface.dart';
import 'package:polkadot_dart/src/metadata/imp/metadata_interface.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';

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

  @override
  RuntimeVersion runtimeVersion() {
    final version = getConstant<Map<String, dynamic>>("System", "Version");
    return RuntimeVersion.deserializeJson(version);
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
  int getCallLookupId(String palletNameOrIndex) {
    return metadata.getCallLookupId(palletNameOrIndex);
  }
}
