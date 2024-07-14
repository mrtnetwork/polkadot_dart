import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/extrinsic/layouts/v4.dart';
import 'package:polkadot_dart/src/models/generic/models/signature.dart';
import 'package:polkadot_dart/src/models/generic/models/multi_address.dart';
import 'package:polkadot_dart/src/models/generic/models/era.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class ExtrinsicSignature extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateMultiSignature signature;
  final SubstrateMultiAddress address;
  final SubstrateBaseEra era;
  final BigInt? tip;
  final int nonce;
  final int mode;
  const ExtrinsicSignature(
      {required this.signature,
      required this.address,
      required this.era,
      this.tip,
      required this.nonce,
      this.mode = 0});

  @override
  StructLayout layout({String? property}) =>
      ExtrinsicV4Layouts.signatureV4(property: "property");

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
