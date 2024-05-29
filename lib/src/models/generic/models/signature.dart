import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';
import 'package:polkadot_dart/src/models/generic/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';
import 'fixed_bytes.dart';

abstract class SubstrateBaseSignature extends ScaleFixedBytes {
  SubstrateBaseSignature.fromHex(String hex, int lengthInBytes)
      : super.fromHex(hex, lengthInBytes: lengthInBytes);
  SubstrateBaseSignature(List<int> bytes, int lengthInBytes)
      : super(bytes, lengthInBytes: lengthInBytes);
  abstract final String name;
}

class SubstrateSr25519Signature extends SubstrateBaseSignature {
  SubstrateSr25519Signature(List<int> bytes)
      : super(bytes, SubstrateConstant.signatureLength);
  SubstrateSr25519Signature.fromHex(String hex)
      : super.fromHex(hex, SubstrateConstant.signatureLength);

  @override
  String get name => GenericConstants.multiSignatureSr25519IndexKey;
}

class SubstrateED25519Signature extends SubstrateBaseSignature {
  SubstrateED25519Signature(List<int> bytes)
      : super(bytes, SubstrateConstant.signatureLength);
  SubstrateED25519Signature.fromHex(String hex)
      : super.fromHex(hex, SubstrateConstant.signatureLength);

  @override
  String get name => GenericConstants.multiSignatureEd25519IndexKey;
}

class SubstrateEcdsaSignature extends SubstrateBaseSignature {
  SubstrateEcdsaSignature(List<int> bytes)
      : super(bytes, SubstrateConstant.ecdsaSignatureLength);
  SubstrateEcdsaSignature.fromHex(String hex)
      : super.fromHex(hex, SubstrateConstant.ecdsaSignatureLength);

  @override
  String get name => GenericConstants.multiSignatureEcdsaIndexKey;
}

class SubstrateMultiSignature
    extends SubstrateSerialization<Map<String, dynamic>> {
  final SubstrateBaseSignature signature;
  const SubstrateMultiSignature(this.signature);

  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      GenericLayouts.signature(property: property);

  List<int> signatureBytes() {
    return List<int>.from(signature.bytes);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {signature.name: signature.scaleJsonSerialize()};
  }
}
