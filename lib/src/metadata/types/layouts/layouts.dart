import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/generic/types/type_def_primitive.dart';
import 'package:polkadot_dart/src/metadata/types/si/si1/si1_type.defs.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/storage_entery_type_v14.dart';
import 'package:polkadot_dart/src/metadata/types/v9/types/storage_entry_modifier.dart';
import 'package:polkadot_dart/src/metadata/types/v11/types/storage_hasher.dart';

/// Serialization layout related to metadata v15,v14
class SubstrateMetadataLayouts {
  static CompactIntLayout si1LookupTypeId({String? property}) {
    return LayoutConst.compactIntU32(property: property);
  }

  static Layout siLookupTypeId({String? property}) {
    return si1LookupTypeId(property: property);
  }

  static Layout si0Path({String? property}) {
    return LayoutConst.compactVec(LayoutConst.compactString(),
        property: property);
  }

  static Layout si1Path({String? property}) {
    return si0Path(property: property);
  }

  static StructLayout si1TypeParameter({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      LayoutConst.optional(si1LookupTypeId(), property: "type")
    ]);
  }

  static StructLayout si1Field({String? property}) {
    return LayoutConst.struct([
      LayoutConst.optional(LayoutConst.compactString(), property: "name"),
      si1LookupTypeId(property: "type"),
      LayoutConst.optional(LayoutConst.compactString(), property: "typeName"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ]);
  }

  static StructLayout si1TypeDefComposite({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactVec(si1Field(), property: "fields")],
        property: property);
  }

  static StructLayout si1Variant({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      LayoutConst.compactVec(si1Field(), property: "fields"),
      LayoutConst.u8(property: "index"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ]);
  }

  static StructLayout si1TypeDefSequence({String? property}) {
    return LayoutConst.struct([si1LookupTypeId(property: "type")],
        property: property);
  }

  static StructLayout si1TypeDefArray({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.u32(property: "len"), si1LookupTypeId(property: "type")],
        property: property);
  }

  static CustomLayout<Map<String, dynamic>, List<int>> si1TypeDefTuple(
      {String? property}) {
    return LayoutConst.compactVec<int>(si1LookupTypeId(), property: property);
  }

  static Layout<Map<String, dynamic>> si0TypeDefPrimitive({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.none(property: PrimitiveTypes.boolType.name),
      LayoutConst.none(property: PrimitiveTypes.charType.name),
      LayoutConst.none(property: PrimitiveTypes.strType.name),
      LayoutConst.none(property: PrimitiveTypes.u8.name),
      LayoutConst.none(property: PrimitiveTypes.u16.name),
      LayoutConst.none(property: PrimitiveTypes.u32.name),
      LayoutConst.none(property: PrimitiveTypes.u64.name),
      LayoutConst.none(property: PrimitiveTypes.u128.name),
      LayoutConst.none(property: PrimitiveTypes.u256.name),
      LayoutConst.none(property: PrimitiveTypes.i8.name),
      LayoutConst.none(property: PrimitiveTypes.i16.name),
      LayoutConst.none(property: PrimitiveTypes.i32.name),
      LayoutConst.none(property: PrimitiveTypes.i64.name),
      LayoutConst.none(property: PrimitiveTypes.i128.name),
      LayoutConst.none(property: PrimitiveTypes.i256.name),
    ], property: property, useKeyAndValue: false);
  }

  static Layout si1TypeDefPrimitive({String? property}) {
    return si0TypeDefPrimitive(property: property);
  }

  static StructLayout si1TypeDefCompact({String? property}) {
    return LayoutConst.struct([si1LookupTypeId(property: "type")],
        property: property);
  }

  static StructLayout si1TypeDefBitSequence({String? property}) {
    return LayoutConst.struct([
      si1LookupTypeId(property: "bitStoreType"),
      si1LookupTypeId(property: "bitOrderType"),
    ], property: property);
  }

  static Layout<String> type({String? property}) {
    return LayoutConst.compactString(property: property);
  }

  static StructLayout si1TypeDefVariant({String? property}) {
    return LayoutConst.struct(
        [LayoutConst.compactVec(si1Variant(), property: "variants")],
        property: property);
  }

  static Layout<Map<String, dynamic>> si1TypeDef({String? property}) {
    return LayoutConst.rustEnum([
      si1TypeDefComposite(property: Si1TypeDefsIndexesConst.composite.name),
      si1TypeDefVariant(property: Si1TypeDefsIndexesConst.variant.name),
      si1TypeDefSequence(property: Si1TypeDefsIndexesConst.sequence.name),
      si1TypeDefArray(property: Si1TypeDefsIndexesConst.array.name),
      si1TypeDefTuple(property: Si1TypeDefsIndexesConst.tuple.name),
      si1TypeDefPrimitive(property: Si1TypeDefsIndexesConst.primitive.name),
      si1TypeDefCompact(property: Si1TypeDefsIndexesConst.compact.name),
      si1TypeDefBitSequence(property: Si1TypeDefsIndexesConst.bitSequence.name),
      type(property: Si1TypeDefsIndexesConst.historicMetaCompat.name)
    ], property: property, useKeyAndValue: false);
  }

  static StructLayout si1Type({String? property}) {
    return LayoutConst.struct([
      si1Path(property: "path"),
      LayoutConst.compactVec(si1TypeParameter(), property: "params"),
      si1TypeDef(property: "def"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs"),
    ], property: property);
  }

  static StructLayout portableTypeV14({String? property}) {
    return LayoutConst.struct([
      si1LookupTypeId(property: "id"),
      si1Type(property: "type"),
    ], property: property);
  }

  static StructLayout portableType({String? property}) {
    return portableTypeV14(property: property);
  }

  static StructLayout portableRegistry({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactVec(portableType(), property: "types"),
    ], property: property);
  }

  static StructLayout signedExtensionMetadataV14({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "identifier"),
      siLookupTypeId(property: "type"),
      siLookupTypeId(property: "additionalSigned"),
    ], property: property);
  }

  static StructLayout extrinsicMetadataV14({String? property}) {
    return LayoutConst.struct([
      siLookupTypeId(property: "type"),
      LayoutConst.u8(property: "version"),
      LayoutConst.compactVec(signedExtensionMetadataV14(),
          property: "signedExtensions"),
    ], property: property);
  }

  static StructLayout extrinsicMetadataV15({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "version"),
      siLookupTypeId(property: "addressType"),
      siLookupTypeId(property: "callType"),
      siLookupTypeId(property: "signatureType"),
      siLookupTypeId(property: "extraType"),
      LayoutConst.compactVec(signedExtensionMetadataV14(),
          property: "signedExtensions"),
    ], property: property);
  }

  static StructLayout optionMetadata({String? property}) {
    return LayoutConst.struct([
      siLookupTypeId(property: "type"),
    ], property: property);
  }

  static Layout<Map<String, dynamic>> storageEntryModifierV9(
      {String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.none(property: StorageEntryModifierV9.optional.name),
      LayoutConst.none(property: StorageEntryModifierV9.def.name),
      LayoutConst.none(property: StorageEntryModifierV9.required.name),
    ], property: property, useKeyAndValue: false);
  }

  static Layout<Map<String, dynamic>> storageEntryModifierV14(
      {String? property}) {
    return storageEntryModifierV9(property: property);
  }

  static Layout<Map<String, dynamic>> storageHasherV11({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.none(property: StorageHasherV11Options.blake2128.name),
      LayoutConst.none(property: StorageHasherV11Options.blake2256.name),
      LayoutConst.none(property: StorageHasherV11Options.blake2128Concat.name),
      LayoutConst.none(property: StorageHasherV11Options.twox128.name),
      LayoutConst.none(property: StorageHasherV11Options.twox256.name),
      LayoutConst.none(property: StorageHasherV11Options.twox64Concat.name),
      LayoutConst.none(property: StorageHasherV11Options.identity.name),
    ], property: property, useKeyAndValue: false);
  }

  static Layout<Map<String, dynamic>> storageHasherV14({String? property}) {
    return storageHasherV11(property: property);
  }

  static Layout<Map<String, dynamic>> storageEnteryTypeMap({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactVec(storageHasherV14(), property: "hashers"),
      siLookupTypeId(property: "key"),
      siLookupTypeId(property: "value"),
    ], property: property);
  }

  static Layout<Map<String, dynamic>> storageEntryTypeV14({String? property}) {
    return LayoutConst.rustEnum([
      siLookupTypeId(property: StorageEntryTypeV14IndexKeys.plain),
      storageEnteryTypeMap(property: StorageEntryTypeV14IndexKeys.map),
    ], property: property, useKeyAndValue: false);
  }

  static StructLayout storageEntryMetadataV14({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      storageEntryModifierV14(property: "modifier"),
      storageEntryTypeV14(property: "type"),
      LayoutConst.bytes(property: "fallback"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ], property: property);
  }

  static StructLayout palletStorageMetadataV14({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "prefix"),
      LayoutConst.compactVec(storageEntryMetadataV14(), property: "items")
    ], property: property);
  }

  static StructLayout palletCallMetadataV14({String? property}) {
    return LayoutConst.struct([siLookupTypeId(property: "type")],
        property: property);
  }

  static StructLayout palletEventMetadataV14({String? property}) {
    return LayoutConst.struct([siLookupTypeId(property: "type")],
        property: property);
  }

  static StructLayout palletConstantMetadataV14({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      siLookupTypeId(property: "type"),
      LayoutConst.bytes(property: "value"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ], property: property);
  }

  static StructLayout palletErrorMetadataV14({String? property}) {
    return LayoutConst.struct([siLookupTypeId(property: "type")],
        property: property);
  }

  static StructLayout palletMetadataV14({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      LayoutConst.optional(palletStorageMetadataV14(), property: "storage"),
      LayoutConst.optional(palletCallMetadataV14(), property: "calls"),
      LayoutConst.optional(palletEventMetadataV14(), property: "events"),
      LayoutConst.compactVec(palletConstantMetadataV14(),
          property: "constants"),
      LayoutConst.optional(palletErrorMetadataV14(), property: "errors"),
      LayoutConst.u8(property: "index")
    ], property: property);
  }

  static StructLayout palletMetadataV15({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      LayoutConst.optional(palletStorageMetadataV14(), property: "storage"),
      LayoutConst.optional(palletCallMetadataV14(), property: "calls"),
      LayoutConst.optional(palletEventMetadataV14(), property: "events"),
      LayoutConst.compactVec(palletConstantMetadataV14(),
          property: "constants"),
      LayoutConst.optional(palletErrorMetadataV14(), property: "errors"),
      LayoutConst.u8(property: "index"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ], property: property);
  }

  static StructLayout metadataV14({String? property}) {
    return LayoutConst.struct([
      portableRegistry(property: "lookup"),
      LayoutConst.compactVec(palletMetadataV14(), property: "pallets"),
      extrinsicMetadataV14(property: "extrinsic"),
      siLookupTypeId(property: "type")
    ], property: property);
  }

  static StructLayout runtimeApiMethodParamMetadataV15({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      si1LookupTypeId(property: "type")
    ], property: property);
  }

  static StructLayout runtimeApiMethodMetadataV15({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      LayoutConst.compactVec(runtimeApiMethodParamMetadataV15(),
          property: "inputs"),
      si1LookupTypeId(property: "output"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ], property: property);
  }

  static StructLayout outerEnums15({String? property}) {
    return LayoutConst.struct([
      si1LookupTypeId(property: "callType"),
      si1LookupTypeId(property: "eventType"),
      si1LookupTypeId(property: "errorType"),
    ], property: property);
  }

  static StructLayout runtimeApiMetadataV15({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactString(property: "name"),
      LayoutConst.compactVec(runtimeApiMethodMetadataV15(),
          property: "methods"),
      LayoutConst.compactVec(LayoutConst.compactString(), property: "docs")
    ], property: property);
  }

  static StructLayout customMetadata15({String? property}) {
    return LayoutConst.struct([
      LayoutConst.compactMap<String, dynamic>(
          LayoutConst.compactString(), customValueMetadata15(),
          property: "map"),
    ], property: property);
  }

  static StructLayout metadataV15({String? property}) {
    return LayoutConst.struct([
      portableRegistry(property: "lookup"),
      LayoutConst.compactVec(palletMetadataV15(), property: "pallets"),
      extrinsicMetadataV15(property: "extrinsic"),
      siLookupTypeId(property: "type"),
      LayoutConst.compactVec(runtimeApiMetadataV15(), property: "apis"),
      outerEnums15(property: "outerEnums"),
      customMetadata15(property: "custom")
    ], property: property);
  }

  static StructLayout customValueMetadata15({String? property}) {
    return LayoutConst.struct([
      siLookupTypeId(property: "type"),
      LayoutConst.bytes(property: "value"),
    ], property: property);
  }

  static StructLayout metadataMagicAndVersion({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u32(property: "magicNumber"),
      LayoutConst.u8(property: "version"),
    ], property: property);
  }

  static StructLayout versionedMetadata(
    Layout metadata, {
    String? property,
  }) {
    return LayoutConst.struct([
      LayoutConst.u32(property: "magicNumber"),
      LayoutConst.u8(property: "version"),
      metadata
    ], property: property);
  }
}
