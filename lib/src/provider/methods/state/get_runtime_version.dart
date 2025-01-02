import 'package:polkadot_dart/src/models/generic/models/runtime_version.dart';
import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Get the runtime version.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetRuntimeVersion
    extends SubstrateRequest<Map<String, dynamic>, RuntimeVersion> {
  const SubstrateRequestStateGetRuntimeVersion({this.blockHash});

  final String? blockHash;

  /// state_getRuntimeVersion
  @override
  String get rpcMethod => SubstrateRequestMethods.getRuntimeVersion.value;

  @override
  List<dynamic> toJson() {
    return [blockHash];
  }

  @override
  RuntimeVersion onResonse(Map<String, dynamic> result) {
    return RuntimeVersion.fromJson(result);
  }
}
