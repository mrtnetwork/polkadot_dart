import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/rpc/rpc_methods.dart';

/// Retrieves the list of RPC methods that are exposed by the node.
/// https://polkadot.js.org/docs/substrate/rpc/#rpc
class SubstrateRequestRpcMethods
    extends SubstrateRequest<Map<String, dynamic>, RpcMethods> {
  const SubstrateRequestRpcMethods();

  /// rpc_methods
  @override
  String get rpcMethod => SubstrateRequestMethods.rpc.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  RpcMethods onResonse(Map<String, dynamic> result) {
    return RpcMethods.fromJson(result);
  }
}
