import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Retrieves the storage hash.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetStorageHash
    extends SubstrateRPCRequest<String, String> {
  const SubstrateRPCStateGetStorageHash({
    required this.key,
    this.atBlockHash,
  });
  final String key;
  final String? atBlockHash;

  /// state_getStorageHash
  @override
  String get rpcMethod => SubstrateRPCMethods.stateGetStorageHash.value;

  @override
  List<dynamic> toJson() {
    return [key, atBlockHash];
  }
}

/// getStorageHash(key: StorageKey, at?: BlockHash): Hash
