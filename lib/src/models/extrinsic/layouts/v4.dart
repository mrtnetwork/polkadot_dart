import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';

class ExtrinsicV4Layouts {
  static StructLayout payloadV4({String? property}) {
    return LayoutConst.struct([
      LayoutConst.greedyArray(LayoutConst.u8(), property: "method"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),
      LayoutConst.u32(property: "specVersion"),
      LayoutConst.u32(property: "transactionVersion"),
      LayoutConst.fixedBlob32(property: "genesisHash"),
      LayoutConst.fixedBlob32(property: "blockHash"),
      LayoutConst.optional(LayoutConst.fixedBlob32(), property: "metadataHash"),
    ], property: property);
  }

  static StructLayout signatureV4({String? property}) {
    return LayoutConst.struct([
      GenericLayouts.multiAddress(property: "address"),
      GenericLayouts.signature(property: "signature"),
      GenericLayouts.era(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  } // metadataHash

  static StructLayout genericExtrinssicSigned({String? property}) {
    return LayoutConst.struct([
      LayoutConst.u8(property: "version"),
      signatureV4(property: "signature")
    ], property: property);
  }

  static StructLayout genericExtrinssicUnsigned({String? property}) {
    return LayoutConst.struct([LayoutConst.u8(property: "version")],
        property: property);
  }
}
