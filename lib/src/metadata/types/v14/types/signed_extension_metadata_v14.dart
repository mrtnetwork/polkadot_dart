import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/signed_extension_metadata.dart';

class SignedExtensionMetadataV14 extends SignedExtensionMetadata {
  SignedExtensionMetadataV14.deserializeJson(super.json)
      : super.deserializeJson();
  SignedExtensionMetadataV14(
      {required super.identifier,
      required super.type,
      required super.additionalSigned});
}
