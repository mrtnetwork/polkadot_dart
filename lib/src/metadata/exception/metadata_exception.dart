import 'package:blockchain_utils/exception/exception.dart';

/// Exception class for metadata-related errors in the Substrate framework.
class MetadataException extends BlockchainUtilsException {
  const MetadataException(String message, {Map<String, dynamic>? details})
      : super(message, details: details);
}
