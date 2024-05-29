import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns true if the keystore has private keys for the given public key and key type.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRPCAuthorHasKey extends SubstrateRPCRequest<bool, bool> {
  const SubstrateRPCAuthorHasKey(
      {required this.publicKey, required this.keyType});
  final String publicKey;
  final String keyType;

  /// author_hasKey
  @override
  String get rpcMethod => SubstrateRPCMethods.hasKey.value;

  @override
  List<dynamic> toJson() {
    return [publicKey, keyType];
  }
}
