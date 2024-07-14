import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Adds a reserved peer
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemAddReservedPeer
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemAddReservedPeer(this.peerId);
  final String peerId;

  /// system_addReservedPeer
  @override
  String get rpcMethod => SubstrateRPCMethods.addReservedPeer.value;

  @override
  List<dynamic> toJson() {
    return [peerId];
  }
}
