import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the size of a child storage entry at a block state.
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRequestChildStateGetStorageSize
    extends SubstrateRequest<int?, int?> {
  const SubstrateRequestChildStateGetStorageSize({
    required this.childKey,
    required this.key,
    this.atBlockHash,
  });
  final String childKey;

  final String key;
  final String? atBlockHash;

  /// childstate_getStorageSize
  @override
  String get rpcMethod => SubstrateRequestMethods.getStorageSize.value;

  @override
  List<dynamic> toJson() {
    return [childKey, key, atBlockHash];
  }
}
