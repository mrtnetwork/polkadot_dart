import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the chain type.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemChainType extends SubstrateRequest<String, String> {
  const SubstrateRequestSystemChainType();

  /// system_chainType
  @override
  String get rpcMethod => SubstrateRequestMethods.chainType.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
