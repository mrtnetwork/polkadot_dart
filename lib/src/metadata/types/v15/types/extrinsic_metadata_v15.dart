import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/types/layouts/layouts.dart';
import 'package:polkadot_dart/src/metadata/types/v14/types/signed_extension_metadata_v14.dart';
import 'package:polkadot_dart/src/metadata/types/versioned/extrinsic/extrinsic_metadata.dart';

class ExtrinsicMetadataV15 extends ExtrinsicMetadata {
  final int version;
  final int addressType;
  final int callType;
  final int signatureType;
  final int extraType;
  final List<SignedExtensionMetadataV14> signedExtensions;
  ExtrinsicMetadataV15(
      {required this.addressType,
      required this.version,
      required this.callType,
      required this.signatureType,
      required this.extraType,
      required List<SignedExtensionMetadataV14> signedExtensions})
      : signedExtensions =
            List<SignedExtensionMetadataV14>.unmodifiable(signedExtensions);
  ExtrinsicMetadataV15.deserializeJson(Map<String, dynamic> json)
      : signedExtensions = List<SignedExtensionMetadataV14>.unmodifiable(
            (json["signedExtensions"] as List)
                .map((e) => SignedExtensionMetadataV14.deserializeJson(e))),
        addressType = json["addressType"],
        callType = json["callType"],
        signatureType = json["signatureType"],
        extraType = json["extraType"],
        version = json["version"];

  @override
  Layout<Map<String, dynamic>> layout({String? property}) {
    return SubstrateMetadataLayouts.extrinsicMetadataV15(property: property);
  }

  @override
  Map<String, dynamic> scaleJsonSerialize({String? property}) {
    return {
      "version": version,
      "addressType": addressType,
      "callType": callType,
      "signatureType": signatureType,
      "extraType": extraType,
      "signedExtensions":
          signedExtensions.map((e) => e.scaleJsonSerialize()).toList(),
    };
  }
}
