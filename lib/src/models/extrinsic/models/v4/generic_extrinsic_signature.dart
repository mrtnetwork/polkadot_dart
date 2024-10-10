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
      {required SubstrateMultiSignature signature,
      required SubstrateMultiAddress address,
      required SubstrateBaseEra era,
      required BigInt? tip,
      required int nonce})
      : super(
            signature: signature,
            address: address,
            era: era,
            tip: tip,
            nonce: nonce);
}

class ExtrinsicSignature extends BaseExtrinsicSignature {
  final int mode;

  ExtrinsicSignature(
      {required SubstrateMultiSignature signature,
      required SubstrateMultiAddress address,
      required SubstrateBaseEra era,
      required BigInt? tip,
      required int nonce,
      this.mode = 0})
      : super(
            signature: signature,
            address: address,
            era: era,
            tip: tip,
            nonce: nonce);

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
      "mode": mode
    };
  }
}
