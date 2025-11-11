import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the best finalized header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainSubscribeFinalizedHeads
    extends SubstrateRequest<String, String> {
  const SubstrateRequestChainSubscribeFinalizedHeads();

  /// chain_subscribeFinalizedHeads
  @override
  String get rpcMethod => SubstrateRequestMethods.subscribeFinalizedHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
