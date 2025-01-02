import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the storage hash.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetStorageHash
    extends SubstrateRequest<String, String> {
  const SubstrateRequestStateGetStorageHash({
    required this.key,
    this.atBlockHash,
  });
  final String key;
  final String? atBlockHash;

  /// state_getStorageHash
  @override
  String get rpcMethod => SubstrateRequestMethods.stateGetStorageHash.value;

  @override
  List<dynamic> toJson() {
    return [key, atBlockHash];
  }
}

/// getStorageHash(key: StorageKey, at?: BlockHash): Hash
