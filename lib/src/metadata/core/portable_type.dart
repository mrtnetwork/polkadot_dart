import 'package:polkadot_dart/src/metadata/core/scale_versioned.dart';

/// Abstract class representing a portable type in the Substrate framework.
abstract class PortableType {
  /// The identifier for the portable type.
  abstract final int id;

  /// The versioned type definition for the portable type.
  abstract final ScaleInfoVersioned type;
}
