import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Insert a key into the keystore.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRPCAuthorInsertKey extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCAuthorInsertKey(
      {required this.publicKey, required this.keyType, required this.suri});
  final String publicKey;
  final String suri;
  final String keyType;

  /// author_insertKey
  @override
  String get rpcMethod => SubstrateRPCMethods.insertKey.value;

  @override
  List<dynamic> toJson() {
    return [
      keyType,
      suri,
      publicKey,
    ];
  }
}
