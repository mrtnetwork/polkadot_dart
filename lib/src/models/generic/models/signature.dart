import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/constant/constant.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/models/generic/constant/constant.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

import 'fixed_bytes.dart';

abstract class SubstrateBaseSignature extends ScaleFixedBytes {
  SubstrateBaseSignature.fromHex(super.hex, int lengthInBytes)
      : super.fromHex(lengthInBytes: lengthInBytes);
  SubstrateBaseSignature(super.bytes, int lengthInBytes)
      : super(lengthInBytes: lengthInBytes);
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
  factory SubstrateMultiSignature.deserialize(List<int> bytes) {
    final json = SubstrateVariantSerialization.deserialize(
        bytes: bytes, layout: layout_());
    final variant = SubstrateVariantSerialization.toVariantDecodeResult(json);
    final bytesValue = (variant.result["value"] as List).cast<int>();
    final signature = switch (variant.variantName) {
      GenericConstants.multiSignatureSr25519IndexKey =>
        SubstrateSr25519Signature(bytesValue),
      GenericConstants.multiSignatureEd25519IndexKey =>
        SubstrateED25519Signature(bytesValue),
      GenericConstants.multiSignatureEcdsaIndexKey =>
        SubstrateSr25519Signature(bytesValue),
      _ => throw DartSubstratePluginException("Unsuported signature type.")
    };
    return SubstrateMultiSignature(signature);
  }
  static Layout<Map<String, dynamic>> layout_({String? property}) {
    return LayoutConst.rustEnum([
      LayoutConst.fixedBlobN(SubstrateConstant.signatureLength,
          property: GenericConstants.multiSignatureEd25519IndexKey),
      LayoutConst.fixedBlobN(SubstrateConstant.signatureLength,
          property: GenericConstants.multiSignatureSr25519IndexKey),
      LayoutConst.fixedBlobN(SubstrateConstant.ecdsaSignatureLength,
          property: GenericConstants.multiSignatureEcdsaIndexKey),
    ], property: property);
  }

  @override
  Layout<Map<String, dynamic>> layout({String? property}) =>
      layout_(property: property);

  List<int> signatureBytes() {
    return List<int>.from(signature.bytes);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {signature.name: signature.serializeJson()};
  }
}
