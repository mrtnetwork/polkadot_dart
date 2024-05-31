import 'package:polkadot_dart/src/models/generic/models/runtime_version.dart';
import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Get the runtime version.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetRuntimeVersion
    extends SubstrateRPCRequest<Map<String, dynamic>, RuntimeVersion> {
  const SubstrateRPCStateGetRuntimeVersion({this.blockHash});

  final String? blockHash;

  /// state_getRuntimeVersion
  @override
  String get rpcMethod => SubstrateRPCMethods.getRuntimeVersion.value;

  @override
  List<dynamic> toJson() {
    return [blockHash];
  }

  @override
  RuntimeVersion onResonse(Map<String, dynamic> result) {
    return RuntimeVersion.fromJson(result);
  }
}
