import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns the base58-encoded PeerId of the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemLocalPeerId
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemLocalPeerId();

  /// system_localPeerId
  @override
  String get rpcMethod => SubstrateRPCMethods.localPeerId.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
