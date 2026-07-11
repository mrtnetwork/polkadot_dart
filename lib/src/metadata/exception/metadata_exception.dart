import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:polkadot_dart/src/exception/exception.dart';
import 'package:polkadot_dart/src/serialization/identifier.dart';

/// Exception class for metadata-related errors in the Substrate framework.
class MetadataException extends BaseDartSubstratePluginException {
  const MetadataException(super.message, {super.details});
  factory MetadataException.deserialize({List<int>? bytes, CborObject? obj}) {
    final values = CborTagSerializable.decodeTaggedValue(
      cborBytes: bytes,
      cborObject: obj,
      identifier: PolkadotSerializationIdentifiers.metadataError,
    );
    return MetadataException(
      values.rawValueAt(0),
      details: values.maybeRawMapAt<String, String?>(1),
    );
  }
  @override
  PolkadotSerializationIdentifiers get serializationIdentifier =>
      PolkadotSerializationIdentifiers.metadataError;
}
