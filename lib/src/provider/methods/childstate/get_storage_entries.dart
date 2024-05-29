import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Returns child storage entries for multiple keys at a specific block state
/// https://polkadot.js.org/docs/substrate/rpc/#childstate
class SubstrateRPCChildStateGetStorageEntries
    extends SubstrateRPCRequest<List<dynamic>, List<String?>> {
  const SubstrateRPCChildStateGetStorageEntries(
      {required this.childKey, required this.keys, this.atBlockHash});

  final String childKey;
  final List<String> keys;
  final String? atBlockHash;

  /// childstate_getStorageEntries
  @override
  String get rpcMethod => SubstrateRPCMethods.getStorageEntries.value;

  @override
  List<dynamic> toJson() {
    return [childKey, keys, atBlockHash];
  }

  @override
  List<String?> onResonse(List result) {
    return result.cast();
  }
}
