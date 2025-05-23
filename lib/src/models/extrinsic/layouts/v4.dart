import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class ExtrinsicV4Layouts {
  static StructLayout payloadV4({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),

      /// signatureType
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),

      /// additional signed (need in payload)
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
      LayoutConst.optional(LayoutConst.fixedBlob32(), property: "metadataHash"),
    ], property: property);
  }

  static StructLayout assetPayoad({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.optional(LayoutConst.blob(LayoutConst.greedy()),
          property: "asset"),
      LayoutConst.u8(property: "mode"),
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
      LayoutConst.optional(LayoutConst.fixedBlob32(), property: "metadataHash"),
    ], property: property);
  }

  static StructLayout legacyPayloadV4({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
    ], property: property);
  }

  static StructLayout signatureV4({String? property}) {
    return LayoutConst.struct([
      GenericLayouts.multiAddress(property: "address"),
      GenericLayouts.signature(property: "signature"),

      /// signedExtensions type ids
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  }

  static StructLayout monoBeanSignatureV4({String? property}) {
    return LayoutConst.struct([
      LayoutConst.fixedBlobN(20, property: "address"),
      LayoutConst.fixedBlobN(65, property: "signature"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  }

  static StructLayout assetSignatureV4({String? property}) {
    return LayoutConst.struct([
      GenericLayouts.multiAddress(property: "address"),
      GenericLayouts.signature(property: "signature"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.optional(LayoutConst.blob(LayoutConst.greedy()),
          property: "asset"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  }

  static StructLayout legacySignatureV4({String? property}) {
    return LayoutConst.struct([
      GenericLayouts.multiAddress(property: "address"),
      GenericLayouts.signature(property: "signature"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
    ], property: property);
  }

  static StructLayout genericExtrinssicUnsigned({String? property}) {
    return LayoutConst.struct([LayoutConst.u8(property: "version")],
        property: property);
  }
}
