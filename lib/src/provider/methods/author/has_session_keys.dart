import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns true if the keystore has private keys for the given session public keys.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRequestAuthorHasSessionKeys
    extends SubstrateRequest<bool, bool> {
  const SubstrateRequestAuthorHasSessionKeys({required this.sessionKeys});
  final String sessionKeys;

  /// author_hasSessionKeys
  @override
  String get rpcMethod => SubstrateRequestMethods.hasSessionKeys.value;

  @override
  List<dynamic> toJson() {
    return [sessionKeys];
  }
}
