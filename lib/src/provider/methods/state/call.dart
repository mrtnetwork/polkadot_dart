import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Perform a call to a builtin on the chain.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateCall extends SubstrateRequest<String, String> {
  const SubstrateRequestStateCall({
    required this.method,
    required this.data,
    this.atBlockHash,
  });
  final String method;
  final String data;
  final String? atBlockHash;

  /// state_call
  @override
  String get rpcMethod => SubstrateRequestMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return [method, data, if (atBlockHash != null) atBlockHash];
  }
}
