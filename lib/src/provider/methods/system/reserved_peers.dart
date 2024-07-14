import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the list of reserved peers
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemReservedPeers
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCSystemReservedPeers();

  /// system_reservedPeers
  @override
  String get rpcMethod => SubstrateRPCMethods.reservedPeers.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
