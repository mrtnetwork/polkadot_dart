import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/signed_extension_metadata.dart';

class SignedExtensionMetadataV14 extends SignedExtensionMetadata {
  /// The type of the additional signed data, with the data to be included in the signed payload
  final int additionalSigned;

  SignedExtensionMetadataV14.deserializeJson(super.json)
      : additionalSigned = json["additionalSigned"],
        super.deserializeJson();
  SignedExtensionMetadataV14(
      {required super.identifier,
      required super.type,
      required this.additionalSigned});

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      ...super.scaleJsonSerialize(property: property),
      "additionalSigned": additionalSigned
    };
  }
}
