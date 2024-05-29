import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Subscribes to storage changes for the provided keys
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateSubscribeStorage
    extends SubstrateRPCRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRPCStateSubscribeStorage(this.keys);
  final List<String> keys;

  /// state_subscribeStorage
  @override
  String get rpcMethod => SubstrateRPCMethods.subscribeStorage.value;

  @override
  List<dynamic> toJson() {
    return [keys];
  }
}
