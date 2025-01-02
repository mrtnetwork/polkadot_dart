import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns child storage entries for multiple keys at a specific block state
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRequestChildStateGetStorageEntries
    extends SubstrateRequest<List<dynamic>, List<String?>> {
  const SubstrateRequestChildStateGetStorageEntries(
      {required this.childKey, required this.keys, this.atBlockHash});

  final String childKey;
  final List<String> keys;
  final String? atBlockHash;

  /// childstate_getStorageEntries
  @override
  String get rpcMethod => SubstrateRequestMethods.getStorageEntries.value;

  @override
  List<dynamic> toJson() {
    return [childKey, keys, atBlockHash];
  }

  @override
  List<String?> onResonse(List result) {
    return result.cast();
  }
}
