import 'package:polkadot_dart/src/provider/core/base.dart';
import 'package:polkadot_dart/src/provider/core/methods.dart';

/// Retrieves the storage size.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRPCStateGetStorageSize extends SubstrateRPCRequest<int, int> {
  const SubstrateRPCStateGetStorageSize({
    required this.key,
    this.atBlockHash,
  });
  final String key;
  final String? atBlockHash;

  /// state_getStorageSize
  @override
  String get rpcMethod => SubstrateRPCMethods.stateGetStorageSize.value;

  @override
  List<dynamic> toJson() {
    return [key, atBlockHash];
  }
}

/// getStorageHash(key: StorageKey, at?: BlockHash): Hash
