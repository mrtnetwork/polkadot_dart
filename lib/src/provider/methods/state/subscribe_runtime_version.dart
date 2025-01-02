import 'package:polkadot_dart/src/models/generic/models/runtime_version.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the runtime version via subscription
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateSubscribeRuntimeVersion
    extends SubstrateRequest<Map<String, dynamic>, RuntimeVersion> {
  const SubstrateRequestStateSubscribeRuntimeVersion();

  /// state_subscribeRuntimeVersion
  @override
  String get rpcMethod => SubstrateRequestMethods.subscribeRuntimeVersion.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  RuntimeVersion onResonse(Map<String, dynamic> result) {
    return RuntimeVersion.fromJson(result);
  }
}
