import 'package:polkadot_dart/src/exception/exception.dart';

/// Exception class for metadata-related errors in the Substrate framework.
class MetadataException extends DartSubstratePluginException {
  const MetadataException(super.message, {super.details});
}
