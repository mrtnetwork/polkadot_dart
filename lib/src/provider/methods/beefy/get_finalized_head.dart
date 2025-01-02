import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns hash of the latest BEEFY finalized block as seen by this client.
/// https://polkadot.js.org/docs/substrate/rpc/#beefy
class SubstrateRequestBeefyGetFinalizedHead
    extends SubstrateRequest<String, String> {
  const SubstrateRequestBeefyGetFinalizedHead();

  /// beefy_getFinalizedHead
  @override
  String get rpcMethod => SubstrateRequestMethods.getFinalizedHead.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
