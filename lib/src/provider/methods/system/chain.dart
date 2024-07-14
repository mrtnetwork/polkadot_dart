import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the chain.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemChain extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemChain();

  /// system_chain
  @override
  String get rpcMethod => SubstrateRPCMethods.chain.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
