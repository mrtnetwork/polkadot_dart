import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns hash of the latest BEEFY finalized block as seen by this client.
/// https://polkadot.js.org/docs/substrate/rpc/#beefy
class SubstrateRPCBeefyGetFinalizedHead
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCBeefyGetFinalizedHead();

  /// beefy_getFinalizedHead
  @override
  String get rpcMethod => SubstrateRPCMethods.getFinalizedHead.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
