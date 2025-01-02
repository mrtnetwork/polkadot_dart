import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the chain.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemChain extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemChain();

  /// system_chain
  @override
  String get rpcMethod => SubstrateRequestMethods.chain.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
