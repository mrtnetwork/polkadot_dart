import 'package:polkadot_dart/src/provider/core/core/base.dart';
import 'package:polkadot_dart/src/provider/core/core/methods.dart';

/// Returns proof of storage entries at a specific block state.
/// https://polkadot.js.org/docs/substrate/rpc/#state
class SubstrateRequestStateGetReadProof
    extends SubstrateRequest<Map<String, dynamic>, Map<String, dynamic>> {
  const SubstrateRequestStateGetReadProof({
    required this.keys,
    this.atBlockHash,
  });
  final List<String> keys;
  final String? atBlockHash;

  /// state_getReadProof
  @override
  String get rpcMethod => SubstrateRequestMethods.getReadProof.value;

  @override
  List<dynamic> toJson() {
    return [keys, atBlockHash];
  }
}

/// getReadProof(keys: Vec<StorageKey>, at?: BlockHash): ReadProof
