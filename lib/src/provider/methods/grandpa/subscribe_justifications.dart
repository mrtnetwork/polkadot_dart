import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Subscribes to grandpa justifications
/// https://polkadot.js.org/docs/substrate/rpc/#grandpa
class SubstrateRPCGrandpaSubscribeJustifications
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCGrandpaSubscribeJustifications();

  /// grandpa_subscribeJustifications
  @override
  String get rpcMethod =>
      SubstrateRPCMethods.grandpaSubscribeJustifications.value;

  @override
  List<dynamic> toJson() {
    return [];
  }
}
