import 'package:blockchain_utils/exception/exception.dart';

/// Exception class for metadata-related errors in the Substrate framework.
class MetadataException extends BlockchainUtilsException {
  /// The error message for this exception.
  @override
  final String message;

  /// Additional details about the exception.
  @override
  final Map<String, dynamic>? details;

  /// Creates a new MetadataException with the provided [message] and optional [details].
  MetadataException(this.message, {Map<String, dynamic>? details})
      : details = details == null
            ? null
            : Map.unmodifiable(
                details..removeWhere((key, value) => value == null));

  /// Returns a string representation of this exception.
  @override
  String toString() {
    final detailsValues =
        details?.keys.map((e) => "$e: ${details![e]}").join(", ") ?? "";
    return "MetadataException: $message${detailsValues.isEmpty ? '' : ' $detailsValues'}";
  }
}
