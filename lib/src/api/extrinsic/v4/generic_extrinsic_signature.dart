import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
import 'package:polkadot_dart/src/models/generic/models/multi_address.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

abstract class BaseExtrinsicSignature
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateMultiSignature signature;
  final SubstrateMultiAddress address;
  final SubstrateBaseEra era;
  final BigInt? tip;
  final int nonce;
  const BaseExtrinsicSignature(
      {required this.signature,
      required this.address,
      required this.era,
      required this.tip,
      required this.nonce});

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "signature": signature.serializeJson(),
      "address": address.serializeJson(),
      "era": era.serializeJson(),
      "tip": tip ?? BigInt.zero,
      "nonce": nonce
    };
  }

  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      SubstrateMultiAddress.layout_(property: "address"),
      SubstrateMultiSignature.layout_(property: "signature"),
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);
}

class LegacyExtrinsicSignature extends BaseExtrinsicSignature {
  const LegacyExtrinsicSignature(
      {required super.signature,
      required super.address,
      required super.era,
      required super.tip,
      required super.nonce});
}

class ExtrinsicSignature extends BaseExtrinsicSignature {
  final int mode;

  ExtrinsicSignature(
      {required super.signature,
      required super.address,
      required super.era,
      required super.tip,
      required super.nonce,
      this.mode = 0});
  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      SubstrateMultiAddress.layout_(property: "address"),
      SubstrateMultiSignature.layout_(property: "signature"),

      /// signedExtensions type ids
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "signature": signature.serializeJson(),
      "address": address.serializeJson(),
      "era": era.serializeJson(),
      "tip": tip ?? BigInt.zero,
      "nonce": nonce,
      "mode": mode,
    };
  }
}

class AssetExtrinsicSignature extends ExtrinsicSignature {
  final List<int>? asset;
  AssetExtrinsicSignature(
      {required super.signature,
      required super.address,
      required super.era,
      required super.tip,
      required super.nonce,
      super.mode = 0,
      List<int>? asset})
      : asset = asset?.immutable;
  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      SubstrateMultiAddress.layout_(property: "address"),
      SubstrateMultiSignature.layout_(property: "signature"),
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.optional(LayoutConst.blob(LayoutConst.greedy()),
          property: "asset"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {...super.serializeJson(property: property), "asset": asset};
  }
}

class EthereumExtrinsicSignature extends ExtrinsicSignature {
  EthereumExtrinsicSignature(
      {required super.signature,
      required super.address,
      required super.era,
      super.tip,
      required super.nonce,
      super.mode});
  static StructLayout layout_({String? property}) {
    return LayoutConst.struct([
      LayoutConst.fixedBlobN(20, property: "address"),
      LayoutConst.fixedBlobN(65, property: "signature"),
      SubstrateBaseEra.layout_(property: "era"),
      LayoutConst.compactIntU32(property: "nonce"),
      LayoutConst.compactBigintU128(property: "tip"),
      LayoutConst.u8(property: "mode"),
    ], property: property);
  }

  @override
  StructLayout layout({String? property}) => layout_(property: property);

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "signature": signature.signatureBytes(),
      "address": address.value.accountBytes(),
      "era": era.serializeJson(),
      "tip": tip ?? BigInt.zero,
      "nonce": nonce,
      "mode": mode,
    };
  }
}
