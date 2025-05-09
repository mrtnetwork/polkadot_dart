import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns the keys with prefix from a child storage, leave empty to get all the keys
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRequestChildStateGetKeys
    extends SubstrateRequest<List<dynamic>, List<String>> {
  const SubstrateRequestChildStateGetKeys(
      {required this.childKey, required this.prefix, this.atBlockHash});
  final String childKey;
  final String prefix;
  final String? atBlockHash;

  /// childstate_getKeys
  @override
  String get rpcMethod => SubstrateRequestMethods.getKeys.value;

  @override
  List<dynamic> toJson() {
    return [childKey, prefix, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
