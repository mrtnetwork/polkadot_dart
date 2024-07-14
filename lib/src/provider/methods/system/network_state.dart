import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns current state of the network
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemNetworkState
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCSystemNetworkState();

  /// system_networkState
  @override
  String get rpcMethod => SubstrateRPCMethods.networkState.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
