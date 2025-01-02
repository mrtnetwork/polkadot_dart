import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// The addresses include a trailing /p2p/ with the local PeerId,
/// and are thus suitable to be passed to addReservedPeer or as a bootnode address for example
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemLocalListenAddresses
    extends SubstrateRequest<List<dynamic>, List<String>> {
  const SubstrateRequestSystemLocalListenAddresses();

  /// system_localListenAddresses
  @override
  String get rpcMethod => SubstrateRequestMethods.localListenAddresses.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
