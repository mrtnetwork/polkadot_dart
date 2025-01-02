import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the block most recently finalized by BEEFY, alongside its justification.
/// https://polkadot.js.org/docs/substrate/rpc/#beefy
class SubstrateRequestBeefySubscribeJustifications
    extends SubstrateRequest<dynamic, dynamic> {
  const SubstrateRequestBeefySubscribeJustifications();

  /// beefy_subscribeJustifications
  @override
  String get rpcMethod => SubstrateRequestMethods.subscribeJustifications.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
