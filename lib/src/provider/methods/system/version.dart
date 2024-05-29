import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Retrieves the version of the node.
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemVersion extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCSystemVersion();

  /// system_version
  @override
  String get rpcMethod => SubstrateRPCMethods.version.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
