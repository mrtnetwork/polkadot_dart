import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Get hash of the last finalized block in the canon chain
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainChainGetFinalizedHead
    extends SubstrateRequest<String, String> {
  const SubstrateRequestChainChainGetFinalizedHead();

  /// chain_getFinalizedHead
  @override
  String get rpcMethod => SubstrateRequestMethods.chainGetFinalizedHead.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
