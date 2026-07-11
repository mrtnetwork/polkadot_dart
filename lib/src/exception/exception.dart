import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/networks/types/network.dart';
import 'package:polkadot_dart/src/metadata/exception/metadata_exception.dart';
import 'package:polkadot_dart/src/serialization/serialization.dart';

abstract class BaseDartSubstratePluginException extends IException {
  const BaseDartSubstratePluginException(super.message, {super.details});
  factory BaseDartSubstratePluginException.deserialize({
    List<int>? bytes,
    CborObject? obj,
  }) {
    final values = CborTagSerializable.decodeTaggedValueWithInfo(
      cborBytes: bytes,
      cborObject: obj,
      expectedTags: PolkadotSerializationIdentifiers.values,
    );
    final identifier = values.identifier;
    return switch (identifier) {
      PolkadotSerializationIdentifiers.plokadotPluginError =>
        DartSubstratePluginException.deserialize(obj: values.tag),
      PolkadotSerializationIdentifiers.metadataError =>
        MetadataException.deserialize(obj: values.tag),
    };
  }

  @override
  PolkadotSerializationIdentifiers get serializationIdentifier;

  @override
  BlockchainNetwork get relatedNetwork => BlockchainNetwork.substrateAndRelated;
}

class DartSubstratePluginException extends BaseDartSubstratePluginException {
  const DartSubstratePluginException(super.message, {super.details});
  factory DartSubstratePluginException.deserialize({
    List<int>? bytes,
    CborObject? obj,
  }) {
    final values = CborTagSerializable.decodeTaggedValue(
      cborBytes: bytes,
      cborObject: obj,
      identifier: PolkadotSerializationIdentifiers.plokadotPluginError,
    );
    return DartSubstratePluginException(
      values.rawValueAt(0),
      details: values.maybeRawMapAt<String, String?>(1),
    );
  }
  @override
  PolkadotSerializationIdentifiers get serializationIdentifier =>
      PolkadotSerializationIdentifiers.plokadotPluginError;
}
