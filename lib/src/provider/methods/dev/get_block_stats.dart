import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Reexecute the specified block_hash and gather statistics while doing so
/// https://polkadot.js.org/docs/substrate/rpc/#dev
class SubstrateRPCDevGetBlockStats
    extends SubstrateRPCRequest<Map<String, dynamic>?, Map<String, dynamic>?> {
  const SubstrateRPCDevGetBlockStats(this.atBlockHash);

  final String atBlockHash;

  /// dev_getBlockStats
  @override
  String get rpcMethod => SubstrateRPCMethods.getBlockStats.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
