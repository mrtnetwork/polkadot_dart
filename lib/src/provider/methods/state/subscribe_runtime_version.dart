import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/state/runtime_version.dart';

/// Retrieves the runtime version via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateSubscribeRuntimeVersion
    extends SubstrateRPCRequest<Map<String, dynamic>, RuntimeVersion> {
  const SubstrateRPCStateSubscribeRuntimeVersion();

  /// state_subscribeRuntimeVersion
  @override
  String get rpcMethod => SubstrateRPCMethods.subscribeRuntimeVersion.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  RuntimeVersion onResonse(Map<String, dynamic> result) {
    return RuntimeVersion.fromJson(result);
  }
}
