import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Remove a reserved peer
/// This method is only active with appropriate flags
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemRemoveReservedPeer
    extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemRemoveReservedPeer(this.peerId);
  final String peerId;

  /// system_removeReservedPeer
  @override
  String get rpcMethod => SubstrateRequestMethods.removeReservedPeer.value;

  @override
  List<dynamic> toJson() {
    return [peerId];
  }
}
