import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the node name
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemName extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemName();

  /// system_name
  @override
  String get rpcMethod => SubstrateRPCMethods.name.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
