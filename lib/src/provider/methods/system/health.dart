import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/system/health.dart';

/// Return health status of the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRPCSystemHealth
    extends SubstrateRPCRequest<Map<String, dynamic>, SystemHealthResppnse> {
  const SubstrateRPCSystemHealth();

  /// system_health
  @override
  String get rpcMethod => SubstrateRPCMethods.systemHealth.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SystemHealthResppnse onResonse(Map<String, dynamic> result) {
    return SystemHealthResppnse.fromJson(result);
  }
}
