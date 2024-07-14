import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns proof of storage for child key entries at a specific block state
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetChildReadProof
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCStateGetChildReadProof({
    required this.childStorageKey,
    required this.keys,
    this.atBlockHash,
  });
  final String childStorageKey;
  final List<String> keys;
  final String? atBlockHash;

  /// state_getChildReadProof
  @override
  String get rpcMethod => SubstrateRPCMethods.getChildReadProof.value;

  @override
  List<dynamic> toJson() {
    return [childStorageKey, keys, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
// getChildReadProof(childStorageKey: PrefixedStorageKey, keys: Vec<StorageKey>, at?: BlockHash): ReadProof
