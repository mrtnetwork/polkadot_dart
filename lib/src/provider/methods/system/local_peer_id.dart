import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the base58-encoded PeerId of the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemLocalPeerId
    extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemLocalPeerId();

  /// system_localPeerId
  @override
  String get rpcMethod => SubstrateRequestMethods.localPeerId.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
