import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Subscribes to storage changes for the provided keys
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateSubscribeStorage
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestStateSubscribeStorage(this.keys);
  final List<String> keys;

  /// state_subscribeStorage
  @override
  String get rpcMethod => SubstrateRequestMethods.subscribeStorage.value;

  @override
  List<dynamic> toJson() {
    return [keys];
  }
}
