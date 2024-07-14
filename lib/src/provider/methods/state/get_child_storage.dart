import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the child storage for a key.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetChildStorage
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCStateGetChildStorage({
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

  /// state_getChildStorage
  @override
  String get rpcMethod => SubstrateRPCMethods.getChildStorage.value;

  @override
  List<dynamic> toJson() {
    return [childStorageKey, childDefinition, childType, key, atBlockHash];
  }
}
