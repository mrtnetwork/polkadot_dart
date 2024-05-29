import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns the size of a child storage entry at a block state.
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRPCChildStateGetStorageSize
    extends SubstrateRPCRequest<int?, int?> {
  const SubstrateRPCChildStateGetStorageSize({
    required this.childKey,
    required this.key,
    this.atBlockHash,
  });
  final String childKey;

  final String key;
  final String? atBlockHash;

  /// childstate_getStorageSize
  @override
  String get rpcMethod => SubstrateRPCMethods.getStorageSize.value;

  @override
  List<dynamic> toJson() {
    return [childKey, key, atBlockHash];
  }
}
