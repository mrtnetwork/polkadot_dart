import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the roles the node is running as
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemNodeRoles
    extends SubstrateRequest<List<dynamic>, List<dynamic>> {
  const SubstrateRequestSystemNodeRoles();

  /// system_nodeRoles
  @override
  String get rpcMethod => SubstrateRequestMethods.nodeRoles.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
