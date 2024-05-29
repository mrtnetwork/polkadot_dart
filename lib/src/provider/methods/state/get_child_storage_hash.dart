import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Retrieves the child storage hash.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetChildStorageHash
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCStateGetChildStorageHash({
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

  /// state_getChildStorageHash
  @override
  String get rpcMethod => SubstrateRPCMethods.getChildStorageHash.value;

  @override
  List<dynamic> toJson() {
    return [childStorageKey, childDefinition, childType, key, atBlockHash];
  }
}
