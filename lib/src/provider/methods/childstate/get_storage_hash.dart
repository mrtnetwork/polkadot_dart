import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the hash of a child storage entry at a block state.
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRPCChildStateGetStorageHash
    extends SubstrateRPCRequest<String?, String?> {
  const SubstrateRPCChildStateGetStorageHash({
    required this.childKey,
    required this.key,
    this.atBlockHash,
  });
  final String childKey;
  final String key;
  final String? atBlockHash;

  /// childstate_getStorageHash
  @override
  String get rpcMethod => SubstrateRPCMethods.getStorageHash.value;

  @override
  List<dynamic> toJson() {
    return [childKey, key, atBlockHash];
  }
}
