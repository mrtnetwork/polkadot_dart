import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/models/extrinsic/layouts/v4.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/extrinsic/models/v4/generic_extrinsic_signature_v.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

class Extrinsic extends SubstrateSerialization<Map<String, dynamic>> {
  final ExtrinsicSignature? signature;
  final List<int> methodBytes;
  const Extrinsic(
      {required this.signature,
      required this.methodBytes,
      this.version = SubstrateConstant.currentExtrinsicVersion});

  final int version;

  bool get isSigned => signature != null;

  @override
  List<int> serialize({String? property, bool encodeLength = true}) {
    final encode = [...super.serialize(), ...methodBytes];
    if (encodeLength) {
      return [...LayoutSerializationUtils.encodeLength(encode), ...encode];
    }
    return encode;
  }

  @override
  StructLayout layout({String? property}) => isSigned
      ? ExtrinsicV4Layouts.genericExtrinssicSigned(property: property)
      : ExtrinsicV4Layouts.genericExtrinssicUnsigned(property: property);

  String toHash() {
    return BytesUtils.toHexString(QuickCrypto.blake2b256Hash(serialize()),
        prefix: "0x");
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    final int version = this.version |
        (isSigned
            ? SubstrateConstant.bitSigned
            : SubstrateConstant.bitUnsigned);
    return {"version": version, "signature": signature?.scaleJsonSerialize()}
      ..removeWhere((key, value) => value == null);
  }
}
