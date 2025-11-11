import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/extrinsic_metadata.dart';

import 'signed_extension_metadata_v14.dart';

class ExtrinsicMetadataV14 extends ExtrinsicMetadata {
  final int version;
  final int type;
  final List<SignedExtensionMetadataV14> signedExtensions;
  ExtrinsicMetadataV14(
      {required this.type,
      required this.version,
      required List<SignedExtensionMetadataV14> signedExtensions})
      : signedExtensions =
            List<SignedExtensionMetadataV14>.unmodifiable(signedExtensions);
  ExtrinsicMetadataV14.deserializeJson(Map<String, dynamic> json)
      : signedExtensions = List<SignedExtensionMetadataV14>.unmodifiable(
            (json["signedExtensions"] as List)
                .map((e) => SignedExtensionMetadataV14.deserializeJson(e))),
        type = json["type"],
        version = json["version"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.extrinsicMetadataV14(property: property);
  }

  @override
  Map<String, dynamic> serializeJson({String? property}) {
    return {
      "signedExtensions":
          signedExtensions.map((e) => e.serializeJson()).toList(),
      "version": version,
      "type": type
    };
  }
}
