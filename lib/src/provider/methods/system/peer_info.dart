import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/system/peer_info.dart';

/// Returns the currently connected peers
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemPeers
    extends SubstrateRequest<List<Map<String, dynamic>>, List<PeerInfo>> {
  const SubstrateRequestSystemPeers();

  /// system_peers
  @override
  String get rpcMethod => SubstrateRequestMethods.peers.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  List<PeerInfo> onResonse(List<Map<String, dynamic>> result) {
    return result.map((e) => PeerInfo.fromJson(e)).toList();
  }
}
