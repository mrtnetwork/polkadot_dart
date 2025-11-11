import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/layout/core/core/core.dart';
import 'package:blockchain_utils/utils/json/extension/json.dart';
import 'package:polkadot_dart/src/api/models/models.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/storage_hasher.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/types/types.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/extrinsic_metadata.dart';
import 'package:polkadot_dart/src/metadata/utils/metadata_utils.dart';

/// Interface providing methods for interacting with the latest metadata in the Substrate framework.
mixin LatestMetadataInterface<PALLET extends PalletMetadata> {
  abstract final int version;

  /// Retrieves the lookup for the given [id].
  Si1Type getLookup(int id) => registry.scaleType(id);

  /// Retrieves the portable registry.
  PortableRegistry get registry;

  bool get supportRuntimeApi =>
      MetadataConstant.supportRuntimeApi.contains(version);

  /// Map containing pallet metadata for version 14.
  abstract final Map<int, PALLET> pallets;

  abstract final ExtrinsicMetadata extrinsic;

  abstract final List<RuntimeApiMetadata> apis;

  /// Decodes a lookup.
  T decodeLookup<T extends Object?>(int id, List<int> bytes,
      {LookupDecodeParams params = const LookupDecodeParams(),
      int offset = 0}) {
    final layout = registry.serializationLayout(id, params: params);
    final data = layout.deserialize(bytes, offset: offset);
    return JsonParser.valueAs<T>(data.value);
  }

  /// encode lookup
  List<int> encodeLookup(
      {required int id, required Object? value, required bool fromTemplate}) {
    final Object? correctValue =
        registry.getValue(id: id, value: value, fromTemplate: fromTemplate);
    final layout = registry.serializationLayout(id);
    final toBytes = layout.serialize(correctValue);
    return toBytes;
  }

  /// Converts a name or index to a pallet index.
  int _toPalletIndex(String nameOrIndex) {
    int? index = int.tryParse(nameOrIndex);
    if (index != null) {
      if (!pallets.containsKey(index)) {
        throw MetadataException("Pallet does not exist.", details: {
          "index": index,
          "pallets": getPalletIndexes().join(", ")
        });
      }
      return index;
    }
    index = pallets.keys.firstWhere(
        (element) =>
            pallets[element]!.name.toLowerCase() == nameOrIndex.toLowerCase(),
        orElse: () => throw MetadataException("Pallet does not exist.",
                details: {
                  "name": nameOrIndex,
                  "pallets": getPalletNames().join(", ")
                }));
    return index;
  }

  /// Retrieves the pallet index by name or index.
  int getPalletIndex(String nameOrIndex) {
    return pallets[_toPalletIndex(nameOrIndex)]!.index;
  }

  /// Retrieves the pallet name by name or index.
  String getPalletName(String nameOrIndex) {
    return pallets[_toPalletIndex(nameOrIndex)]!.name;
  }

  /// Retrieves the pallet metadata by name or index.
  PALLET getPallet(String nameOrIndex) {
    return pallets[_toPalletIndex(nameOrIndex)]!;
  }

  PALLET? tryGetPallet(String nameOrIndex) {
    try {
      return pallets[_toPalletIndex(nameOrIndex)];
    } catch (_) {
      return null;
    }
  }

  T decodeError<T extends Object>(
      {required String nameOrIndex,
      required List<int> bytes,
      LookupDecodeParams params = const LookupDecodeParams()}) {
    final pallet = pallets[_toPalletIndex(nameOrIndex)];
    final error = pallet?.errors?.type;
    if (error == null) {
      throw MetadataException("Error does not exist.",
          details: {"pallet": nameOrIndex});
    }
    return decodeLookup(error, bytes);
  }

  Map<String, dynamic>? decodeErrorWithDescription<T extends Object?>(
      String nameOrIndex, List<int> erorr,
      {LookupDecodeParams params = const LookupDecodeParams()}) {
    final pallet = pallets[_toPalletIndex(nameOrIndex)];
    final type = pallet?.errors?.type;
    if (type != null) {
      final lookup = getLookup(type);
      final variations = (lookup.def as Si1TypeDefVariant).variants;
      final errorVariant =
          variations.firstWhereNullable((e) => e.index == erorr[0]);
      final value =
          decodeLookup<Map<String, dynamic>>(type, erorr, params: params);
      return {...value, "description": errorVariant?.docs};
    }
    return null;
  }

  /// Retrieves the list of pallet indexes.
  List<int> getPalletIndexes() {
    return pallets.keys.toList();
  }

  /// Retrieves the list of pallet names.
  List<String> getPalletNames() {
    return pallets.values.map((e) => e.name).toList();
  }

  /// Retrieves the lookup ID for the given pallet.
  int getCallLookupId(String nameOrIndex) {
    final pallet = getPallet(nameOrIndex);
    if (pallet.calls == null) {
      throw MetadataException("Call does not exist.",
          details: {"pallet": pallet.name});
    }
    return pallet.calls!.type;
  }

  /// Retrieves the storage metadata for the given pallet.
  PalletStorageMetadata getStorage(String palletNameOrIndex) {
    final storage = getPallet(palletNameOrIndex);
    if (storage.storage == null) {
      throw MetadataException("Storage does not exist.",
          details: {"pallet": storage.name});
    }
    return storage.storage!;
  }

  /// Retrieves the storage method metadata for the given pallet and method name.
  StorageEntryMetadataV14 getStorageMethod(
      String palletNameOrIndex, String methodName) {
    final storage = getStorage(palletNameOrIndex);
    final method = storage.items.firstWhere(
      (e) => e.name.toLowerCase() == methodName.toLowerCase(),
      orElse: () =>
          throw MetadataException("Storage method does not exist", details: {
        "pallet": palletNameOrIndex,
        "method": methodName,
        "methods": storage.items.map((e) => e.name).join(", ")
      }),
    );
    return method;
  }

  /// Retrieves the input lookup ID for the given storage method.
  int? getStorageInputId(String palletNameOrIndex, String methodName) {
    return getStorageMethod(palletNameOrIndex, methodName).type.inputTypeId;
  }

  /// Retrieves the output lookup ID for the given storage method.
  int getStorageOutputId(String palletNameOrIndex, String methodName) {
    return getStorageMethod(palletNameOrIndex, methodName).type.outputTypeId;
  }

  /// Retrieves the prefix hash for the given pallet and method name.
  MethodStorageKey getStoragePrefixHash(
      String palletNameOrIndex, String methodName) {
    final storage = getStorage(palletNameOrIndex);
    final method = getStorageMethod(palletNameOrIndex, methodName);
    final prefixHash = MetadataUtils.createQueryPrefixHash(
        prefix: storage.prefix, method: method.name);
    return MethodStorageKey(keyBytes: prefixHash);
  }

  /// Retrieves the list of hashers for the given pallet and method name.
  List<StorageHasher> getStorageHasher(
      String palletNameOrIndex, String methodName) {
    final method = getStorageMethod(palletNameOrIndex, methodName).type;
    if (method is! StorageEntryTypeV14Map) {
      throw const MetadataException(
          "plain storage entery does not have hasher option");
    }
    return method.hashers.map((e) => e.option).toList();
  }

  /// Retrieves the constant value for the given pallet and constant name.
  T getConstant<T extends Object?>(
      String palletNameOrIndex, String constantName) {
    final pallet = getPallet(palletNameOrIndex);
    final constant = pallet.constants.firstWhere(
        (element) => element.name.toLowerCase() == constantName.toLowerCase(),
        orElse: () => throw DartSubstratePluginException(
                "Constant does not exist.",
                details: {
                  "name": constantName,
                  "constants": pallet.constants.map((e) => e.name).join(", ")
                }));
    return decodeLookup(constant.type, constant.value);
  }

  T? tryGetConstant<T extends Object?>(
      String palletNameOrIndex, String constantName) {
    final pallet = tryGetPallet(palletNameOrIndex);
    final constant = pallet?.constants.firstWhereNullable(
        (element) => element.name.toLowerCase() == constantName.toLowerCase());
    if (constant == null) return null;
    return decodeLookup(constant.type, constant.value);
  }

  /// Retrieves all constants for the given pallet.
  Map<String, dynamic> getConstants(String palletNameOrIndex) {
    final pallet = getPallet(palletNameOrIndex);
    final Map<String, dynamic> constants = {};
    for (final constant in pallet.constants) {
      final decode = decodeLookup(constant.type, constant.value);
      constants[constant.name] = decode;
    }
    return constants;
  }

  /// Retrieves all constants for the given pallet.
  Map<String, dynamic> getAllConstants() {
    final Map<String, dynamic> constants = {};
    for (final i in pallets.values) {
      final palletConstants = getConstants(i.name);
      constants[i.name] = palletConstants;
    }
    return constants;
  }

  /// Decodes the storage output for the given pallet and method name.
  T decodeStorageOutput<T extends Object?>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int>? queryResponse}) {
    final StorageEntryMetadataV14 storage =
        getStorageMethod(palletNameOrIndex, methodName);
    if (queryResponse == null && storage.modifier.isOptional) {
      if (null is T) return null as T;
      throw MetadataException(
          "Storage '$palletNameOrIndex.$methodName' is optional, but the provided response is null.");
    }
    final lookupId = getStorageOutputId(palletNameOrIndex, methodName);

    return decodeLookup<T>(lookupId, queryResponse ?? storage.fallback);
  }

  /// Retrieves the list of storage methods for the given pallet.
  List<String> getPalletStorageMethods(String palletNameOrIndex) {
    final pallet = getPallet(palletNameOrIndex);
    return pallet.storage?.items.map((e) => e.name).toList() ?? [];
  }

  bool storageMethodExists(String palletNameOrIndex, String methodName) {
    final pallet = tryGetPallet(palletNameOrIndex);
    return pallet?.storage?.items
            .any((e) => e.name.toLowerCase() == methodName.toLowerCase()) ??
        false;
  }

  bool callMethodExists(String palletNameOrIndex, String methodName) {
    final callId = tryGetPallet(palletNameOrIndex)?.calls?.type;
    if (callId == null) return false;
    final type = getLookup(callId);
    final variants = type.def.cast<Si1TypeDefVariant>().variants;
    return variants
        .any((e) => e.name.toLowerCase() == methodName.toLowerCase());
  }

  bool runtimeMethodExists(String apiName, {String? methodName});

  List<String> getCallMethodNames(String palletNameOrIndex) {
    final callId = tryGetPallet(palletNameOrIndex)?.calls?.type;
    if (callId == null) return [];
    final type = getLookup(callId);
    final variants = type.def.cast<Si1TypeDefVariant>().variants;
    return variants.map((e) => e.name).toList();
  }

  List<String> getRuntimeApis() {
    if (!MetadataConstant.supportRuntimeApi.contains(version)) {
      throw MetadataException(
          "Runtime api only work with metadatas ${MetadataConstant.supportRuntimeApi.join(", ")}");
    }
    throw UnimplementedError();
  }

  List<String> getRuntimeApiMethods(String apiName) {
    if (!MetadataConstant.supportRuntimeApi.contains(version)) {
      throw MetadataException(
          "Runtime api only work with metadatas ${MetadataConstant.supportRuntimeApi.join(", ")}");
    }
    throw UnimplementedError();
  }

  String generateRuntimeApiMethod(String apiName, String methodName) {
    if (!MetadataConstant.supportRuntimeApi.contains(version)) {
      throw MetadataException(
          "Runtime api only work with metadatas ${MetadataConstant.supportRuntimeApi.join(", ")}");
    }
    throw UnimplementedError();
  }

  List<int> getRutimeApiInputLookupIds(String apiName, String methodName) {
    if (!MetadataConstant.supportRuntimeApi.contains(version)) {
      throw MetadataException(
          "Runtime api only work with metadatas ${MetadataConstant.supportRuntimeApi.join(", ")}");
    }
    throw UnimplementedError();
  }

  int getRutimeOutputLookupId(String apiName, String methodName) {
    if (!MetadataConstant.supportRuntimeApi.contains(version)) {
      throw MetadataException(
          "Runtime api only work with metadatas ${MetadataConstant.supportRuntimeApi.join(", ")}");
    }
    throw UnimplementedError();
  }

  List<String> getPaths(int lookupid) {
    return registry.scaleType(lookupid).path;
  }

  List<String> getDocs(int lookupid) {
    return registry.scaleType(lookupid).docs;
  }

  CallInfo _callInfo(String palletNameOrIndex) {
    final callId = getCallLookupId(palletNameOrIndex);
    final type = getLookup(callId);
    final variants = type.def.cast<Si1TypeDefVariant>().variants;
    return CallInfo(
        id: callId,
        palletName: palletNameOrIndex,
        methods: variants
            .map((e) => CallMethodInfo(variant: e, name: e.name, docs: e.docs))
            .toList());
  }

  PalletInfo palletInfo(String palletNameOrIndex) {
    final pallet = getPallet(palletNameOrIndex);
    final constant = pallet.constants.map((e) {
      final value = getConstant(pallet.name, e.name);
      return ConstantInfo(name: e.name, value: value, docs: e.docs);
    }).toList();
    final storage = pallet.storage?.items.map((e) {
      return StorageInfo(
          name: e.name, inputLookupId: e.type.inputTypeId, docs: e.docs);
    }).toList();

    return PalletInfo(
        name: pallet.name,
        contants: constant,
        calls: pallet.calls == null ? null : _callInfo(palletNameOrIndex),
        storage: storage,
        docs: pallet.docs);
  }

  List<TransactionExtrinsicInfo> extrinsicInfo();

  MetadataInfo palletsInfos() {
    final apiMethods = apis
        .map((e) => RuntimeApiInfo(
            docs: e.docs,
            name: e.name,
            methods: e.methods
                .map((e) => RuntimeApiMethodInfo(
                    name: e.name,
                    docs: e.docs,
                    inputs: e.inputs
                        .map((e) =>
                            RuntimeApiInputInfo(name: e.name, lockupId: e.type))
                        .toList()))
                .toList()))
        .toList();
    final pallets = getPalletNames().map((e) => palletInfo(e)).toList();
    return MetadataInfo(
        pallets: pallets, apis: apiMethods, extrinsic: extrinsicInfo());
  }

  int? typeByName(String name) {
    return registry.typeByName(name);
  }

  int? typeByPathTail(String name) {
    return registry.typeByPathTail(name)?.id;
  }

  Layout? typeLayoutByName(String name,
      {String? property, LookupDecodeParams? params}) {
    final lookup = registry.typeByName(name);
    if (lookup == null) return null;

    return registry.serializationLayout(lookup,
        params: params, property: property);
  }

  Layout? typeLayoutByPathTail(String name,
      {String? property, LookupDecodeParams? params}) {
    final lookup = registry.typeByPathTail(name);
    if (lookup == null) return null;

    return registry.serializationLayout(lookup.id,
        params: params, property: property);
  }
}
