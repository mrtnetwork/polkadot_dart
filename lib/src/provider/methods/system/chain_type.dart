import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Retrieves the chain type.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemChainType extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemChainType();

  /// system_chainType
  @override
  String get rpcMethod => SubstrateRPCMethods.chainType.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
