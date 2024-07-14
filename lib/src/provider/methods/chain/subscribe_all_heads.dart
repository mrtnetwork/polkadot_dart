import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/header.dart';

/// Retrieves the newest header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRPCChainSubscribeAllHeads
    extends SubstrateRPCRequest<Map<String, dynamic>, SubstrateHeaderResponse> {
  const SubstrateRPCChainSubscribeAllHeads();

  /// chain_subscribeAllHeads
  @override
  String get rpcMethod => SubstrateRPCMethods.subscribeAllHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SubstrateHeaderResponse onResonse(Map<String, dynamic> result) {
    return SubstrateHeaderResponse.fromJson(result);
  }
}
