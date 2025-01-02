import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Adds a reserved peer
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemAddReservedPeer
    extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemAddReservedPeer(this.peerId);
  final String peerId;

  /// system_addReservedPeer
  @override
  String get rpcMethod => SubstrateRequestMethods.addReservedPeer.value;

  @override
  List<dynamic> toJson() {
    return [peerId];
  }
}
