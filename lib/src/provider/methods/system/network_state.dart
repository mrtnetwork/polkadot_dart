import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns current state of the network
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemNetworkState
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestSystemNetworkState();

  /// system_networkState
  @override
  String get rpcMethod => SubstrateRequestMethods.networkState.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
