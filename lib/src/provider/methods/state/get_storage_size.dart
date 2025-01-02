import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the storage size.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetStorageSize extends SubstrateRequest<int, int> {
  const SubstrateRequestStateGetStorageSize({
    required this.key,
    this.atBlockHash,
  });
  final String key;
  final String? atBlockHash;

  /// state_getStorageSize
  @override
  String get rpcMethod => SubstrateRequestMethods.stateGetStorageSize.value;

  @override
  List<dynamic> toJson() {
    return [key, atBlockHash];
  }
}

/// getStorageHash(key: StorageKey, at?: BlockHash): Hash
