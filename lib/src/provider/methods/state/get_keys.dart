import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Retrieves the keys with a certain prefix
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetKeys
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCStateGetKeys(this.key, {this.atBlockHash});

  final String key;
  final String? atBlockHash;

  /// state_getKeys
  @override
  String get rpcMethod => SubstrateRPCMethods.stateGetKeys.value;

  @override
  List<dynamic> toJson() {
    return [key, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
