import 'package:blockchain_utils/utils/utils.dart';
import 'package:blockchain_utils/layout/layout.dart';
import 'package:polkadot_dart/src/metadata/core/metadata.dart';

class UnsupportedMetadata extends SubstrateMetadata<List<int>> {
  /// The bytes representing the unsupported metadata.
  final List<int> bytes;

  /// The version of the unsupported metadata.
  @override
  final int version;

  /// Constructs an instance of [UnsupportedMetadata] with the provided [bytes] and [version].
  UnsupportedMetadata({required List<int> bytes, required this.version})
      : bytes = BytesUtils.toBytes(bytes, unmodifiable: true);

  /// Returns the serialization layout of the unsupported metadata with optional [property].
  @override
  Layout<List<int>> layout({String? property}) {
    return LayoutConst.blob(bytes.length, property: property);
  }

  /// Serializes the unsupported metadata to scale JSON format with optional [property].
  @override
  List<int> scaleJsonSerialize({String? property}) {
    return bytes;
  }
}
