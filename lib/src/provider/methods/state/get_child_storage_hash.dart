import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the child storage hash.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetChildStorageHash
    extends SubstrateRequest<String, String> {
  const SubstrateRequestStateGetChildStorageHash({
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
  String get rpcMethod => SubstrateRequestMethods.getChildStorageHash.value;

  @override
  List<dynamic> toJson() {
    return [childStorageKey, childDefinition, childType, key, atBlockHash];
  }
}
