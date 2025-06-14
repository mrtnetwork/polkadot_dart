import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/metadata/constant/constant.dart';
import 'package:polkadot_dart/src/metadata/core/portable_registry.dart';
import 'package:polkadot_dart/src/metadata/core/storage_hasher.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/metadata/models/call.dart';
import 'package:polkadot_dart/src/metadata/types/si/si.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/pallet_storage_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/storage_entery_type_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/storage_entry_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v15/types/runtime_api_metadata_v15.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/extrinsic_metadata.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/pallet/metadata.dart';
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
  T decodeLookup<T>(int id, List<int> bytes, {int offset = 0}) {
    final decode = getLookup(id)
        .typeDefDecode(registry: registry, bytes: bytes, offset: offset);
    assert((decode.consumed + offset) == bytes.length, "decode lookup failed.");
    final value = decode.value;
    return MetadataUtils.parseLoockupData<T>(value);
  }

  List<int> encodeLookup(
      {required int id, required Object? value, required bool fromTemplate}) {
    final Object? correctValue =
        registry.getValue(id: id, value: value, fromTemplate: fromTemplate);
    final layout = registry.typeDefLayout(id, correctValue);
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
      orElse: () => throw MetadataException("Storage method does not exist",
          details: {
            "prefix": storage.prefix,
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
  List<int> getStoragePrefixHash(String palletNameOrIndex, String methodName) {
    final storage = getStorage(palletNameOrIndex);
    final method = getStorageMethod(palletNameOrIndex, methodName);
    final prefixHash = MetadataUtils.createQueryPrefixHash(
        prefix: storage.prefix, method: method.name);
    return prefixHash;
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
  T getConstant<T>(String palletNameOrIndex, String constantName) {
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
  T decodeStorageOutput<T>(
      {required String palletNameOrIndex,
      required String methodName,
      required List<int>? queryResponse}) {
    final StorageEntryMetadataV14 storage =
        getStorageMethod(palletNameOrIndex, methodName);
    if (queryResponse == null && storage.modifier.isOptional) {
      return null as T;
    }
    final lookupId = getStorageOutputId(palletNameOrIndex, methodName);
    return decodeLookup<T>(lookupId, queryResponse ?? storage.fallback);
  }

  /// Retrieves the list of storage methods for the given pallet.
  List<String> getPalletStorageMethods(String palletNameOrIndex) {
    final pallet = getPallet(palletNameOrIndex);
    return pallet.storage?.items.map((e) => e.name).toList() ?? [];
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

  String getRuntimeApiMethod(String apiName, String methodName) {
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

  bool get isSupportMetadataHash;

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
}
