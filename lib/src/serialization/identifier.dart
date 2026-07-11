import 'package:blockchain_utils/cbor/serialization/cbor/tag.dart';
import 'package:blockchain_utils/exception/exceptions.dart';

enum PolkadotSerializationIdentifiers implements SerializationIdentifier {
  plokadotPluginError(21001),
  metadataError(21002);

  @override
  final int id;
  const PolkadotSerializationIdentifiers(this.id);

  static PolkadotSerializationIdentifiers fromIdentifier(int? value) {
    return values.firstWhere(
      (e) => e.id == value,
      orElse:
          () =>
              throw ItemNotFoundException(
                name: "PolkadotSerializationIdentifiers",
              ),
    );
  }

  @override
  bool isValid(int? tag) {
    return tag == id;
  }
}
