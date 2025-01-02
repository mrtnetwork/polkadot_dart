import 'package:polkadot_dart/src/serialization/core/serialization.dart';

import 'signed_extension_metadata.dart';

abstract class ExtrinsicMetadata<T extends SignedExtensionMetadata>
    extends SubstrateSerialization<Map<String, dynamic>> {
  final int version;
  abstract final List<T> signedExtensions;
  ExtrinsicMetadata({required this.version});
  ExtrinsicMetadata.deserializeJson(Map<String, dynamic> json)
      : version = json["version"];
  List<int> signingPayloadTypes();
}
