import 'package:polkadot_dart/src/serialization/core/serialization.dart';

/// Abstract class representing metadata in the Substrate blockchain framework.
///
/// This class extends `SubstrateSerialization` and requires a version property.
abstract class SubstrateMetadata<T> extends SubstrateSerialization<T> {
  /// The version of the metadata.
  abstract final int version;
}
