import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';
import 'package:polkadot_dart/src/provider/models/system/health.dart';

/// Return health status of the node
/// https://polkadot.js.org/docs/substrate/rpc/#system
class SubstrateRequestSystemHealth
    extends SubstrateRequest<Map<String, dynamic>, SystemHealthResppnse> {
  const SubstrateRequestSystemHealth();

  /// system_health
  @override
  String get rpcMethod => SubstrateRequestMethods.systemHealth.value;

  @override
  List<dynamic> toJson() {
    return [];
  }

  @override
  SystemHealthResppnse onResonse(Map<String, dynamic> result) {
    return SystemHealthResppnse.fromJson(result);
  }
}
