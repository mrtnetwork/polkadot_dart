import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/extrinsic_metadata.dart';
import 'signed_extension_metadata_v14.dart';

class ExtrinsicMetadataV14 extends ExtrinsicMetadata {
  final int type;
  @override
  final List<SignedExtensionMetadataV14> signedExtensions;
  ExtrinsicMetadataV14(
      {required this.type,
      required super.version,
      required List<SignedExtensionMetadataV14> signedExtensions})
      : signedExtensions =
            List<SignedExtensionMetadataV14>.unmodifiable(signedExtensions);
  ExtrinsicMetadataV14.deserializeJson(super.json)
      : signedExtensions = List<SignedExtensionMetadataV14>.unmodifiable(
            (json["signedExtensions"] as List)
                .map((e) => SignedExtensionMetadataV14.deserializeJson(e))),
        type = json["type"],
        super.deserializeJson();

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.extrinsicMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "signedExtensions":
          signedExtensions.map((e) => e.scaleJsonSerialize()).toList(),
      "version": version,
      "type": type
    };
  }

  @override
  List<int> signingPayloadTypes() {
    return [type, ...signedExtensions.map((e) => e.additionalSigned)];
  }
}
