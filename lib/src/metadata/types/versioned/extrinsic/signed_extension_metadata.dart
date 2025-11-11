import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class SignedExtensionMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  /// The unique signed extension identifier, which may be different from the type name.
  final String identifier;

  /// The type of the signed extension, with the data to be included in the extrinsic.
  final int type;
  const SignedExtensionMetadata({required this.identifier, required this.type});
  SignedExtensionMetadata.deserializeJson(Map<String, dynamic> json)
      : identifier = json["identifier"],
        type = json["type"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.signedExtensionMetadataV14(
        property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "identifier": identifier,
      "type": type,
    };
  }
}
