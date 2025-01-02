import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the keys with a certain prefix
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetKeys
    extends SubstrateRequest<List<dynamic>, List<String>> {
  const SubstrateRequestStateGetKeys(this.key, {this.atBlockHash});

  final String key;
  final String? atBlockHash;

  /// state_getKeys
  @override
  String get rpcMethod => SubstrateRequestMethods.stateGetKeys.value;

  @override
  List<dynamic> toJson() {
    return [key, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
