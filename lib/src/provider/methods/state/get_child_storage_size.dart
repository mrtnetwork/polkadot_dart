import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the child storage size.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetChildStorageSize
    extends SubstrateRequest<int, int> {
  const SubstrateRequestStateGetChildStorageSize({
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

  /// state_getChildStorageSize
  @override
  String get rpcMethod => SubstrateRequestMethods.getChildStorageSize.value;

  @override
  List<dynamic> toJson() {
    return [childStorageKey, childDefinition, childType, key, atBlockHash];
  }
}
