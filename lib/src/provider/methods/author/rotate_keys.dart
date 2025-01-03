import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Generate new session keys and returns the corresponding public keys.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRequestAuthorRotateKeys
    extends SubstrateRequest<String, String> {
  const SubstrateRequestAuthorRotateKeys();

  /// author_rotateKeys
  @override
  String get rpcMethod => SubstrateRequestMethods.rotateKeys.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
