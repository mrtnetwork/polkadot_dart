import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:polkadot_dart/src/api/models/models/storage.dart';
import 'package:polkadot_dart/src/api/models/models/types.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';
import 'package:polkadot_dart/src/models/generic/generic.dart';

class MetadataApi with MetadataApiInterface {
  @override
  final LatestMetadataInterface metadata;
  const MetadataApi(this.metadata);

  /// Returns the underlying registry
  PortableRegistry get registry => metadata.registry;

  /// Returns pallet index by its name
  @override
  int getPalletIndexByName(String name) => metadata.getPalletIndex(name);

  /// Returns pallet name by its index
  @override
  String getPalletNameByIndex(int index) =>
      metadata.getPalletName(index.toString());

  /// Returns type template by ID
  @override
  TypeTemlate getLookupTemplate(int id) {
    return registry.typeTemplate(id);
  }

  /// Checks if a pallet exists
  @override
  bool palletExists(String palletNameOrIndex) =>
      metadata.tryGetPallet(palletNameOrIndex) != null;

  /// Returns template for pallet calls
  @override
  TypeTemlate getCallTemplate(String palletNameOrIndex) {
    return getLookupTemplate(metadata.getCallLookupId(palletNameOrIndex));
  }

  /// Returns template for a specific call method
  @override
  TypeTemlate getCallMethodTemplate(String palletNameOrIndex, String method) {
    final id = metadata.getCallLookupId(palletNameOrIndex);
    final type = metadata.getLookup(id);
    final variants = type.def.cast<Si1TypeDefVariant>();
    return variants.typeTemplate(registry, id, method: method);
  }

  /// Returns type definition by ID
  T getTypeDefination<T extends ScaleTypeDef>(int id) {
    final type = metadata.getLookup(id);
    return type.def.cast<T>();
  }

  /// Encodes a call for a pallet
  @override
  List<int> encodeCall(
      {required String palletNameOrIndex,
      required Object? value,
      bool fromTemplate = false}) {
    final toBytes = encodeLookup(
        id: metadata.getCallLookupId(palletNameOrIndex),
        value: value,
        fromTemplate: fromTemplate);
    return [metadata.getPalletIndex(palletNameOrIndex), ...toBytes];
  }

  /// Encodes a value using a lookup ID
  @override
  List<int> encodeLookup(
      {required int id, required Object? value, required bool fromTemplate}) {
    return metadata.encodeLookup(
        id: id, value: value, fromTemplate: fromTemplate);
  }

  /// Decodes bytes using a lookup ID
  @override
  T decodeLookup<T>(int id, List<int> bytes) {
    final decode = metadata.decodeLookup<T>(id, bytes);
    return decode;
  }

  /// Decodes a pallet call from raw bytes
  @override
  DecodeCallResult decodeCall<T>(List<int> bytes,
      {LookupDecodeParams params = const LookupDecodeParams()}) {
    if (bytes.isEmpty) {
      throw const DartSubstratePluginException("Invalid encoded call bytes.");
    }
    final palletIndex = bytes[0];
    final palletName = getPalletNameByIndex(palletIndex);
    final palletId = metadata.getCallLookupId(palletIndex.toString());
    final decode = metadata
        .getLookup(palletId)
        .serializationLayout(registry, params: params)
        .deserialize(bytes, offset: 1);
    final value = decode.value;
    return DecodeCallResult(
        palletName: palletName,
        data: JsonParser.valueEnsureAsMap<String, dynamic>(value));
  }

  /// Gets a constant from a pallet
  @override
  T getConstant<T>(String palletNameOrIndex, String constantName) =>
      metadata.getConstant(palletNameOrIndex, constantName);

  /// Tries to get a constant, returns null if not found
  @override
  T? tryGetConstant<T>(String palletNameOrIndex, String constantName) =>
      metadata.tryGetConstant(palletNameOrIndex, constantName);

  /// Returns all pallet indexes
  @override
  List<int> getPalletIndexes() => metadata.getPalletIndexes();

  /// Returns all pallet names
  @override
  List<String> getPalletNames() => metadata.getPalletNames();

  /// Returns all constants for a pallet
  @override
  Map<String, dynamic> getConstants(String palletNameOrIndex) =>
      metadata.getConstants(palletNameOrIndex);

  /// Returns all constants in the metadata
  @override
  Map<String, dynamic> getAllConstants() => metadata.getAllConstants();

  /// Returns storage input template for a pallet method, or null
  @override
  TypeTemlate? getStorageInputTemplate(
      String palletNameOrIndex, String methodName) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    if (lookupId == null) return null;
    return getLookupTemplate(lookupId);
  }

  /// Returns storage output template for a pallet method.
  @override
  TypeTemlate getStorageOutputTemplate(
      String palletNameOrIndex, String methodName) {
    final lookupId = metadata.getStorageOutputId(palletNameOrIndex, methodName);
    return getLookupTemplate(lookupId);
  }

  /// Encodes storage input for a pallet method
  @override
  List<int> encodeStorageInput(
      {required String palletNameOrIndex,
      required String methodName,
      required Object? value,
      required bool fromTemplate}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    if (lookupId == null) return [];
    return encodeLookup(id: lookupId, value: value, fromTemplate: fromTemplate);
  }

  /// Decodes storage input from bytes
  @override
  T decodeStorageInput<T>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int> bytes}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    if (lookupId == null) return null as T;
    return decodeLookup(lookupId, bytes);
  }

  /// Decodes storage output from query response
  @override
  T decodeStorageOutput<T extends Object?>(
      {required String palletNameOrIndex,
      required String methodName,
      List<int>? queryResponse}) {
    return metadata.decodeStorageOutput(
        palletNameOrIndex: palletNameOrIndex,
        methodName: methodName,
        queryResponse: queryResponse);
  }

  /// Generates a storage key for the given pallet and method.
  /// Can optionally encode input values or build a partial key.
  @override
  StorageKey generateStorageKey(
      {required String palletNameOrIndex,
      required String methodName,
      bool fromTemplate = false,
      Object? value,

      /// encode input from callback
      ENCODEINPUTS? onEncodeInputs,

      /// only encode part of keys
      bool partial = false}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);

    final prefixHash =
        metadata.getStoragePrefixHash(palletNameOrIndex, methodName);
    if (lookupId == null || (partial && value == null)) {
      return StorageKey(prefix: prefixHash, key: prefixHash.keyHex, inputs: []);
    }
    final hashers = metadata.getStorageHasher(palletNameOrIndex, methodName);
    List<int> methodBytes = [];
    final List<StorageKeyInput> inputs = [];
    if (hashers.length > 1) {
      final lookup = metadata.getLookup(lookupId);
      if (lookup.typeName != Si1TypeDefsIndexesConst.tuple) {
        throw const DartSubstratePluginException(
            "Invalid lookup type. method with mutliple argruments must be tuple");
      }
      final List<int> lookupIds = (lookup.def as TypeDefTuple).values;
      List<dynamic>? listValue;
      List<int>? encode(int index) {
        final type = lookupIds[index];
        final lookup = metadata.getLookup(type);
        if (onEncodeInputs != null) {
          final encode = onEncodeInputs(index, (input) {
            final normalizeInput = lookup.getValue(
                registry: registry,
                value: input,
                fromTemplate: fromTemplate,
                self: type);
            return lookup
                .serializationLayout(registry)
                .serialize(normalizeInput);
          });
          return encode;
        }
        if (partial && value == null) return null;
        listValue ??= MetadataUtils.asList(value);
        if (partial && index >= listValue!.length) return null;
        final input = listValue![index];
        final normalizeInput = lookup.getValue(
            registry: registry,
            value: input,
            fromTemplate: fromTemplate,
            self: type);
        return lookup.serializationLayout(registry).serialize(normalizeInput);
      }

      for (int i = 0; i < hashers.length; i++) {
        final hasher = hashers[i];

        List<int>? encodeBytes = encode(i);
        if (encodeBytes == null) continue;
        final hashedInput = hasher.toHash(encodeBytes);
        methodBytes = [...methodBytes, ...hashedInput];
        inputs.add(
            StorageKeyInput(encodedInput: encodeBytes, input: listValue?[i]));
      }
    } else {
      if (onEncodeInputs != null) {
        methodBytes = onEncodeInputs(
                0,
                (input) => encodeLookup(
                    id: lookupId, value: input, fromTemplate: fromTemplate)) ??
            [];
      } else {
        methodBytes = encodeLookup(
            id: lookupId, value: value, fromTemplate: fromTemplate);
      }

      inputs.add(StorageKeyInput(encodedInput: methodBytes, input: value));
      if (hashers.isNotEmpty) {
        final hasher = hashers[0];
        methodBytes = hasher.toHash(methodBytes);
      }
    }
    final keyBytes = [...prefixHash.keyBytes, ...methodBytes];
    return StorageKey(
        prefix: prefixHash,
        key: BytesUtils.toHexString(keyBytes, prefix: "0x"),
        inputs: inputs);
  }

  /// Decodes a storage key for the given pallet and method.
  /// Works only if the storage hasher includes data.
  StorageKey decodeStorageKey(
      {required String palletNameOrIndex,
      required String methodName,
      required String storageKey,
      LookupDecodeParams params = const LookupDecodeParams()}) {
    final lookupId = metadata.getStorageInputId(palletNameOrIndex, methodName);
    final prefixHash =
        metadata.getStoragePrefixHash(palletNameOrIndex, methodName);
    if (lookupId == null) {
      return StorageKey(prefix: prefixHash, inputs: [], key: storageKey);
    }
    List<int> keyBytes = BytesUtils.fromHexString(storageKey)
        .sublist(prefixHash.keyBytes.length);
    final hashers = metadata.getStorageHasher(palletNameOrIndex, methodName);
    List<StorageKeyInput> inputs = [];

    final lookup = metadata.getLookup(lookupId);
    if (hashers.length > 1) {
      if (lookup.typeName != Si1TypeDefsIndexesConst.tuple) {
        throw const DartSubstratePluginException(
            "Invalid lookup type. method with mutliple argruments must be tuple");
      }
      final List<int> lookupIds = (lookup.def as TypeDefTuple).values;
      int offset = 0;
      for (int i = 0; i < hashers.length; i++) {
        final hasher = hashers[i];
        offset += hasher.hashLength;
        if (hasher.isConcat) {
          final type = lookupIds[i];
          final decode = metadata
              .getLookup(type)
              .serializationLayout(registry, params: params)
              .deserialize(keyBytes, offset: offset);
          inputs.add(StorageKeyInput(
              input: decode.value,
              encodedInput:
                  keyBytes.sublist(offset, offset + decode.consumed)));
          offset += decode.consumed;
          continue;
        }
        inputs.add(StorageKeyInput());
      }
    } else {
      final hasher = hashers.elementAtOrNull(0);
      if (hasher?.isConcat ?? true) {
        final input =
            decodeLookup(lookupId, keyBytes.sublist(hasher?.hashLength ?? 0));
        inputs.add(StorageKeyInput(
            input: input,
            encodedInput: keyBytes.sublist(hasher?.hashLength ?? 0)));
      } else {
        inputs.add(StorageKeyInput());
      }
    }
    return StorageKey(prefix: prefixHash, inputs: inputs, key: storageKey);
  }

  /// Decodes a event from raw bytes.
  @override
  T decodeEvent<T>(
      {String palletNameOrIndex = MetadataConstant.genericSystemPalletName,
      required List<int> bytes,
      int? knownLookupId,
      int offset = 0,
      LookupDecodeParams params = const LookupDecodeParams()}) {
    final event = registry.findEventRecordLookup(knownId: knownLookupId);
    final decode = event
        .serializationLayout(registry, params: params)
        .deserialize(bytes, offset: offset);
    return decode.value;
  }

  /// Generates an event storage key for the specified pallet.
  @override
  MethodStorageKey generateEventStorageKey(
      {String palletNameOrIndex = MetadataConstant.genericSystemPalletName}) {
    final correctName = metadata.getPalletName(palletNameOrIndex);
    return MethodStorageKey(
        keyBytes: MetadataUtils.createEventPrefixHash(prefix: correctName));
  }

  /// get event template
  @override
  TypeTemlate getEventTemplate({int? eventRecordLookupId}) {
    final event = registry.findEventRecordLookup(knownId: eventRecordLookupId);
    return event.typeTemplate(registry, event.type);
  }

  /// get metadata runtime version information.
  @override
  RuntimeVersion runtimeVersion() {
    final version = getConstant<Map<String, dynamic>>("System", "Version");
    return RuntimeVersion.deserializeJson(version);
  }

  /// get ss58 of network
  @override
  int networkSS58Prefix() {
    final prefix = getConstant<int?>("System", "SS58Prefix");
    return prefix ?? 0;
  }

  /// get pallet storage method names
  @override
  List<String> getPalletStorageMethods(String palletNameOrIndex) =>
      metadata.getPalletStorageMethods(palletNameOrIndex);

  /// get all pallets storage method name
  @override
  List<String> getAllPalletsStorageMethods(String palletNameOrIndex) =>
      metadata.getPalletStorageMethods(palletNameOrIndex);

  /// get runtime
  @override
  String generateRuntimeApiMethod(String apiName, String methodName) =>
      metadata.generateRuntimeApiMethod(apiName, methodName);

  /// get runtime api methods
  @override
  List<String> getRuntimeApiMethods(String apiName) {
    return metadata.getRuntimeApiMethods(apiName);
  }

  /// get runtime api names
  @override
  List<String> getRuntimeApis() {
    return metadata.getRuntimeApis();
  }

  /// get runtime method lookup ids
  @override
  List<int> getRuntimeApiInputLookupIds(String apiName, String methodName) {
    return metadata.getRutimeApiInputLookupIds(apiName, methodName);
  }

  /// get runtime method output lookup id
  @override
  int getRuntimeApiOutputLookupId(String apiName, String methodName) {
    return metadata.getRutimeOutputLookupId(apiName, methodName);
  }

  /// get runtime api input methods
  @override
  List<TypeTemlate> getRuntimeApiInputsTemplates(
      String apiName, String methodName) {
    final ids = getRuntimeApiInputLookupIds(apiName, methodName);
    return ids.map((e) => getLookupTemplate(e)).toList();
  }

  /// get runtime api output template.
  @override
  TypeTemlate getRuntimeApiOutputTemplate(String apiName, String methodName) {
    return getLookupTemplate(getRuntimeApiOutputLookupId(apiName, methodName));
  }

  /// encode runtime method inputs
  @override
  List<int> encodeRuntimeApiInputs(
      {required String apiName,
      required String methodName,
      required List<Object?> params,
      bool fromTemplate = true}) {
    final method = generateRuntimeApiMethod(apiName, methodName);
    final inputs = getRuntimeApiInputLookupIds(apiName, methodName);
    if (inputs.length != params.length) {
      throw MetadataException("Invalid params length.", details: {
        "method": method,
        "expected": params.length,
        "length": inputs.length
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

  /// decode runtime api method output
  @override
  T decodeRuntimeApiOutput<T extends Object?>(
      {required String apiName,
      required String methodName,
      required List<int> bytes}) {
    final lookupId = getRuntimeApiOutputLookupId(apiName, methodName);
    return decodeLookup(lookupId, bytes);
  }

  /// get call lookup id
  @override
  int getCallLookupId(String palletNameOrIndex) {
    return metadata.getCallLookupId(palletNameOrIndex);
  }

  /// Decodes a runtime error from bytes using metadata
  T decodeError<T extends Object>({
    required String nameOrIndex,
    required List<int> bytes,
    LookupDecodeParams params = const LookupDecodeParams(),
  }) =>
      metadata.decodeError(
          nameOrIndex: nameOrIndex, bytes: bytes, params: params);

  /// Decodes a runtime error and returns a description, if available
  Map<String, dynamic>? decodeErrorWithDescription<T extends Object?>(
          String nameOrIndex, List<int> erorr,
          {LookupDecodeParams params = const LookupDecodeParams()}) =>
      metadata.decodeErrorWithDescription(nameOrIndex, erorr, params: params);

  /// Checks if the runtime API is supported by this metadata
  bool get supportRuntimeApi => metadata.supportRuntimeApi;

  /// Checks if a storage method exists in a pallet
  bool storageMethodExists(String palletNameOrIndex, String methodName) =>
      metadata.storageMethodExists(palletNameOrIndex, methodName);

  /// Checks if a call method exists in a pallet
  bool callMethodExists(String palletNameOrIndex, String methodName) =>
      metadata.callMethodExists(palletNameOrIndex, methodName);

  /// Checks if a runtime method exists
  bool runtimeMethodExists(String apiName, {String? methodName}) =>
      metadata.runtimeMethodExists(apiName, methodName: methodName);

  /// Returns all call method names for a given pallet
  List<String> getCallMethodNames(String palletNameOrIndex) =>
      metadata.getCallMethodNames(palletNameOrIndex);

  /// Wraps metadata with extrinsic information
  MetadataWithExtrinsic metadataWithExtrinsic() {
    return MetadataWithExtrinsic.fromMetadata(this);
  }

  /// Returns type ID by name
  int? typeByName(String name) => metadata.typeByName(name);

  /// Returns type ID by path tail
  int? typeByPathTail(String name) => metadata.typeByPathTail(name);

  /// Tries to get the layout of a type by name, or returns null if not found
  Layout? tryTypeLayoutByName(String name,
      {String? property, LookupDecodeParams? params}) {
    return metadata.typeLayoutByName(name, params: params, property: property);
  }

  /// Tries to get the layout of a type by path tail, or returns null if not found
  Layout? tryTypeLayoutByPathTail(String name,
      {String? property, LookupDecodeParams? params}) {
    return metadata.typeLayoutByPathTail(name,
        params: params, property: property);
  }

  /// Returns the layout of a type by name or throws if not found
  Layout typeLayoutByName(String name,
      {String? property, LookupDecodeParams? params}) {
    final layout =
        tryTypeLayoutByName(name, params: params, property: property);
    if (layout == null) {
      throw DartSubstratePluginException("Type layout not found.",
          details: {"name": name});
    }
    return layout;
  }

  /// Returns the layout of a type by path tail or throws if not found
  Layout typeLayoutByPathTail(String name,
      {String? property, LookupDecodeParams? params}) {
    final layout =
        tryTypeLayoutByPathTail(name, params: params, property: property);
    if (layout == null) {
      throw DartSubstratePluginException("Path tail layout not found.",
          details: {"name": name});
    }
    return layout;
  }
}
