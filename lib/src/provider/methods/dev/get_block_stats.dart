import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Reexecute the specified block_hash and gather statistics while doing so
/// https://polkadot.js.org/docs/substrate/rpc/#dev
class SubstrateRequestDevGetBlockStats
    extends SubstrateRequest<Map<String, dynamic>?, Map<String, dynamic>?> {
  const SubstrateRequestDevGetBlockStats(this.atBlockHash);

  final String atBlockHash;

  /// dev_getBlockStats
  @override
  String get rpcMethod => SubstrateRequestMethods.getBlockStats.value;

  @override
  List<dynamic> toJson() {
    return [atBlockHash];
  }
}
