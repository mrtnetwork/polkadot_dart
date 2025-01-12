import 'package:polkadot_dart/src/serialization/core/serialization.dart';

abstract class ExtrinsicMetadata
    extends SubstrateSerialization<Map<String, dynamic>> {
  const ExtrinsicMetadata();
}
