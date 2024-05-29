import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

class SignedExtensionMetadataV14
    extends SubstrateSerialization<Map<String, dynamic>> {
  final String identifier;
  final int type;
  final int additionalSigned;
  const SignedExtensionMetadataV14(
      {required this.identifier,
      required this.type,
      required this.additionalSigned});
  SignedExtensionMetadataV14.deserializeJson(Map<String, dynamic> json)
      : identifier = json["identifier"],
        type = json["type"],
        additionalSigned = json["additionalSigned"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.signedExtensionMetadataV14(
        property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "identifier": identifier,
      "type": type,
      "additionalSigned": additionalSigned
    };
  }
}
