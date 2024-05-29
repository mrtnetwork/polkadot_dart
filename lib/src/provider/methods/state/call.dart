import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Perform a call to a builtin on the chain.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateCall extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCStateCall({
    required this.method,
    required this.data,
    this.atBlockHash,
  });
  final String method;
  final String data;
  final String? atBlockHash;

  /// state_call
  @override
  String get rpcMethod => SubstrateRPCMethods.stateCall.value;

  @override
  List<dynamic> toJson() {
    return [method, data, atBlockHash];
  }
}
