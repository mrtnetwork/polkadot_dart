import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Insert a key into the keystore.
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#author
class SubstrateRequestAuthorInsertKey extends SubstrateRequest<String, String> {
  const SubstrateRequestAuthorInsertKey(
      {required this.publicKey, required this.keyType, required this.suri});
  final String publicKey;
  final String suri;
  final String keyType;

  /// author_insertKey
  @override
  String get rpcMethod => SubstrateRequestMethods.insertKey.value;

  @override
  List<dynamic> toJson() {
    return [
      keyType,
      suri,
      publicKey,
    ];
  }
}
