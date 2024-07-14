import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Get hash of the last finalized block in the canon chain
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainChainGetFinalizedHead
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCChainChainGetFinalizedHead();

  /// chain_getFinalizedHead
  @override
  String get rpcMethod => SubstrateRPCMethods.chainGetFinalizedHead.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
