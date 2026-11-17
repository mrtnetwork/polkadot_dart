import 'package:blockchain_utils/blockchain_utils.dart';

enum PolkadotSerializationIdentifiers implements SerializationIdentifier {
  polkadotPluginError(21001),
  metadataError(21002);

  @override
  final int id;
  const PolkadotSerializationIdentifiers(this.id);

  static PolkadotSerializationIdentifiers fromIdentifier(int? value) {
    return values.firstWhere(
      (e) => e.id == value,
      orElse:
          () =>
              throw BuError(DefaultErrorType.notFound, "No matching PolkadotSerializationIdentifiers found for the given value. null"),
    );
  }

  @override
  bool isValid(int? tag) {
    return tag == id;
  }
}
