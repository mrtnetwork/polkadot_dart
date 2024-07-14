import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Remove a reserved peer
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemRemoveReservedPeer
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemRemoveReservedPeer(this.peerId);
  final String peerId;

  /// system_removeReservedPeer
  @override
  String get rpcMethod => SubstrateRPCMethods.removeReservedPeer.value;

  @override
  List<dynamic> toJson() {
    return [peerId];
  }
}
