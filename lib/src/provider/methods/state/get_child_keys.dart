import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the keys with prefix of a specific child storage.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetChildKeys
    extends SubstrateRPCRequest<List<dynamic>, List<String>> {
  const SubstrateRPCStateGetChildKeys({
    required this.childStorageKey,
    required this.childDefinition,
    required this.childType,
    required this.key,
    this.atBlockHash,
  });
  final String childStorageKey;
  final String childDefinition;
  final int childType;
  final String key;
  final String? atBlockHash;

  /// state_getChildKeys
  @override
  String get rpcMethod => SubstrateRPCMethods.getChildKeys.value;

  @override
  List<dynamic> toJson() {
    return [childStorageKey, childDefinition, childType, key, atBlockHash];
  }

  @override
  List<String> onResonse(List result) {
    return result.cast();
  }
}
