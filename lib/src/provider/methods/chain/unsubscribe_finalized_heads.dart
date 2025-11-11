import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the best finalized header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainUnSubscribeFinalizedHeads
    extends SubstrateRequest<Null, Null> {
  const SubstrateRequestChainUnSubscribeFinalizedHeads();

  /// chain_subscribeFinalizedHeads
  @override
  String get rpcMethod =>
      SubstrateRequestMethods.unsubscribeFinalizedHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
