import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns true if the keystore has private keys for the given session public keys.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRPCAuthorHasSessionKeys extends SubstrateRPCRequest<bool, bool> {
  const SubstrateRPCAuthorHasSessionKeys({required this.sessionKeys});
  final String sessionKeys;

  /// author_hasSessionKeys
  @override
  String get rpcMethod => SubstrateRPCMethods.hasSessionKeys.value;

  @override
  List<dynamic> toJson() {
    return [sessionKeys];
  }
}
