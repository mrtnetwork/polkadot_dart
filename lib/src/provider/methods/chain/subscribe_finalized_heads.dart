import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/header.dart';

/// Retrieves the best finalized header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainSubscribeFinalizedHeads
    extends SubstrateRPCRequest<Map<String, dynamic>, SubstrateHeaderResponse> {
  const SubstrateRPCChainSubscribeFinalizedHeads();

  /// chain_subscribeFinalizedHeads
  @override
  String get rpcMethod => SubstrateRPCMethods.subscribeFinalizedHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SubstrateHeaderResponse onResonse(Map<String, dynamic> result) {
    return SubstrateHeaderResponse.fromJson(result);
  }
}
