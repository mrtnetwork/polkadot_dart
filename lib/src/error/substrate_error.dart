import 'package:blockchain_utils/blockchain_utils.dart';

/// Substrate/Polkadot-specific error types. Phase 2: taxonomy only, no serialization.
enum SubstrateErrorType implements BuErrorType {
  plugin(16000),
  metadata(16001),
  blockLookupNotFound(16002),
  blockNotFound(16003);

  @override
  String get domain => 'substrate';

  @override
  String get errName => name;

  @override
  final int id;
  const SubstrateErrorType(this.id);

  @override
  bool isValid(int? tag) {
    return values.any((e) => e.id == tag);
  }
}

/// Canonical block-lookup failures. Thrown instances are `const`, so
/// identity/equality checks (`e == blockNotFound`) keep working.
abstract final class SubstrateLookupBlockExceptionConst {
  /// Block body not found for a known block id (lookup returned no block).
  static const notFound = BuError(
    SubstrateErrorType.blockLookupNotFound,
    "Failed to locate block: item not found.",
  );

  /// Block hash not found (unknown or pruned block id).
  static const blockNotFound = BuError(
    SubstrateErrorType.blockNotFound,
    "Failed to locate block: block not found.",
  );
}
