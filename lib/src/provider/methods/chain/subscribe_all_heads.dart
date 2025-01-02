import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/chain/header.dart';

/// Retrieves the newest header via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#chain
class SubstrateRequestChainSubscribeAllHeads
    extends SubstrateRequest<Map<String, dynamic>, SubstrateHeaderResponse> {
  const SubstrateRequestChainSubscribeAllHeads();

  /// chain_subscribeAllHeads
  @override
  String get rpcMethod => SubstrateRequestMethods.subscribeAllHeads.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SubstrateHeaderResponse onResonse(Map<String, dynamic> result) {
    return SubstrateHeaderResponse.fromJson(result);
  }
}
