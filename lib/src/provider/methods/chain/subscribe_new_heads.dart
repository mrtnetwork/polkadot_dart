import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the best header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainSubscribeNewHeads
    extends SubstrateRequest<String, String> {
  const SubstrateRequestChainSubscribeNewHeads();

  /// chain_subscribeNewHeads
  @override
  String get rpcMethod => SubstrateRequestMethods.subscribeNewHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
