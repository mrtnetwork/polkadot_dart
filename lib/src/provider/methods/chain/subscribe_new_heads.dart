import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/header.dart';

/// Retrieves the best header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainSubscribeNewHeads
    extends SubstrateRPCRequest<Map<String, dynamic>, SubstrateHeaderResponse> {
  const SubstrateRPCChainSubscribeNewHeads();

  /// chain_subscribeNewHeads
  @override
  String get rpcMethod => SubstrateRPCMethods.subscribeNewHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SubstrateHeaderResponse onResonse(Map<String, dynamic> result) {
    return SubstrateHeaderResponse.fromJson(result);
  }
}
