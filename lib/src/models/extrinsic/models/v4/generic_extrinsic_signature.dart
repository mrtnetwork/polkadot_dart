import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/extrinsic/layouts/v4.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';
import 'package:polkadot_dart/src/models/generic/models/multi_address.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
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
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "signature": signature.scaleJsonSerialize(),
      "address": address.scaleJsonSerialize(),
      "era": era.scaleJsonSerialize(),
      "tip": tip ?? BigInt.zero,
      "nonce": nonce
    };
  }

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.legacySignatureV4(property: property);
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

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.signatureV4(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "signature": signature.scaleJsonSerialize(),
      "address": address.scaleJsonSerialize(),
      "era": era.scaleJsonSerialize(),
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

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.assetSignatureV4(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {...super.scaleJsonSerialize(property: property), "asset": asset};
  }
}

class MoonbeamExtrinsicSignature extends ExtrinsicSignature {
  MoonbeamExtrinsicSignature(
      {required super.signature,
      required super.address,
      required super.era,
      super.tip,
      required super.nonce,
      super.mode});

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.monoBeanSignatureV4(property: property);

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "signature": signature.signatureBytes(),
      "address": address.value.accountBytes(),
      "era": era.scaleJsonSerialize(),
      "tip": tip ?? BigInt.zero,
      "nonce": nonce,
      "mode": mode,
    };
  }
}
